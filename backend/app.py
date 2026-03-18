import os
import difflib
from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "yemek_app"),
    "charset": "utf8mb4",
}


def get_db():
    return mysql.connector.connect(**DB_CONFIG)


# ---------------------------------------------------------------------------
# GET /api/malzemeler  – tüm malzemeleri listele
# ---------------------------------------------------------------------------
@app.route("/api/malzemeler", methods=["GET"])
def get_malzemeler():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        """
        SELECT m.id, m.ad, k.id AS kategori_id, k.ad AS kategori_ad, k.ikon AS kategori_ikon
        FROM malzemeler m
        JOIN kategoriler k ON m.kategori_id = k.id
        ORDER BY k.ad, m.ad
        """
    )
    malzemeler = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(malzemeler)


# ---------------------------------------------------------------------------
# GET /api/kategoriler  – tüm kategorileri listele
# ---------------------------------------------------------------------------
@app.route("/api/kategoriler", methods=["GET"])
def get_kategoriler():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM kategoriler ORDER BY ad")
    kategoriler = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(kategoriler)


# ---------------------------------------------------------------------------
# POST /api/malzeme-dogrula  – malzeme geçerliliğini kontrol et
# Body: { "malzeme": "taş" }
# ---------------------------------------------------------------------------
@app.route("/api/malzeme-dogrula", methods=["POST"])
def malzeme_dogrula():
    data = request.get_json(silent=True) or {}
    girilen = data.get("malzeme", "").strip()

    if not girilen:
        return jsonify({"gecerli": False, "mesaj": "Malzeme adı boş olamaz.", "oneriler": []}), 400

    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT ad FROM malzemeler")
    tum_malzemeler = [row["ad"] for row in cursor.fetchall()]
    cursor.close()
    conn.close()

    # Büyük/küçük harf duyarsız tam eşleşme
    eslesme = next((m for m in tum_malzemeler if m.lower() == girilen.lower()), None)
    if eslesme:
        return jsonify({"gecerli": True, "malzeme": eslesme, "oneriler": []})

    # Benzer malzeme önerileri (difflib)
    oneriler = difflib.get_close_matches(girilen, tum_malzemeler, n=5, cutoff=0.4)

    # Substring eşleşmesini de ekle
    substring_eslesmeleri = [m for m in tum_malzemeler if girilen.lower() in m.lower() and m not in oneriler]
    oneriler = list(dict.fromkeys(oneriler + substring_eslesmeleri))[:5]

    return jsonify({
        "gecerli": False,
        "mesaj": f'"{girilen}" malzeme listemizde bulunamadı.',
        "oneriler": oneriler,
    })


# ---------------------------------------------------------------------------
# POST /api/tarif-onerisi  – malzemelere göre tarif öner
# Body: { "malzemeler": ["domates", "soğan", "tavuk"] }
# ---------------------------------------------------------------------------
@app.route("/api/tarif-onerisi", methods=["POST"])
def tarif_onerisi():
    data = request.get_json(silent=True) or {}
    girilen_malzemeler = [m.strip().lower() for m in (data.get("malzemeler") or []) if m.strip()]

    if not girilen_malzemeler:
        return jsonify({"error": "En az bir malzeme giriniz."}), 400

    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    # Her tarif için toplam malzeme sayısı ve eşleşen malzeme sayısı
    cursor.execute(
        """
        SELECT
            t.id,
            t.ad,
            t.aciklama,
            t.zorluk,
            t.pisirme_suresi,
            t.porsiyon,
            COUNT(tm.malzeme_id) AS toplam_malzeme
        FROM tarifler t
        JOIN tarif_malzemeleri tm ON t.id = tm.tarif_id
        GROUP BY t.id, t.ad, t.aciklama, t.zorluk, t.pisirme_suresi, t.porsiyon
        """
    )
    tarifler = cursor.fetchall()

    # Her tarif için malzeme listesini al
    cursor.execute(
        """
        SELECT tm.tarif_id, m.ad AS malzeme_ad, tm.miktar
        FROM tarif_malzemeleri tm
        JOIN malzemeler m ON tm.malzeme_id = m.id
        """
    )
    tarif_malzeme_rows = cursor.fetchall()
    cursor.close()
    conn.close()

    # tarif_id -> malzeme listesi
    tarif_malzeme_map = {}
    for row in tarif_malzeme_rows:
        tid = row["tarif_id"]
        if tid not in tarif_malzeme_map:
            tarif_malzeme_map[tid] = []
        tarif_malzeme_map[tid].append({"ad": row["malzeme_ad"], "miktar": row["miktar"]})

    sonuclar = []
    for tarif in tarifler:
        tid = tarif["id"]
        tarif_malzemeleri_listesi = tarif_malzeme_map.get(tid, [])
        tarif_malzeme_adlari = [m["ad"].lower() for m in tarif_malzemeleri_listesi]

        eslesen = [m for m in girilen_malzemeler if m in tarif_malzeme_adlari]
        eslesen_sayi = len(eslesen)

        if eslesen_sayi == 0:
            continue

        eslesme_yuzdesi = round((eslesen_sayi / tarif["toplam_malzeme"]) * 100)

        sonuclar.append({
            "id": tid,
            "ad": tarif["ad"],
            "aciklama": tarif["aciklama"],
            "zorluk": tarif["zorluk"],
            "pisirme_suresi": tarif["pisirme_suresi"],
            "porsiyon": tarif["porsiyon"],
            "eslesme_yuzdesi": eslesme_yuzdesi,
            "eslesen_malzeme_sayisi": eslesen_sayi,
            "toplam_malzeme_sayisi": tarif["toplam_malzeme"],
            "eslesen_malzemeler": eslesen,
            "tum_malzemeler": tarif_malzemeleri_listesi,
        })

    # Eşleşme yüzdesine göre azalan sıralama
    sonuclar.sort(key=lambda x: x["eslesme_yuzdesi"], reverse=True)

    return jsonify(sonuclar)


# ---------------------------------------------------------------------------
# GET /api/tarif/<id>  – tarif detayını getir
# ---------------------------------------------------------------------------
@app.route("/api/tarif/<int:tarif_id>", methods=["GET"])
def get_tarif(tarif_id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM tarifler WHERE id = %s", (tarif_id,))
    tarif = cursor.fetchone()

    if not tarif:
        cursor.close()
        conn.close()
        return jsonify({"error": "Tarif bulunamadı."}), 404

    cursor.execute(
        """
        SELECT m.ad, m.id AS malzeme_id, tm.miktar, k.ad AS kategori_ad, k.ikon AS kategori_ikon
        FROM tarif_malzemeleri tm
        JOIN malzemeler m ON tm.malzeme_id = m.id
        JOIN kategoriler k ON m.kategori_id = k.id
        WHERE tm.tarif_id = %s
        ORDER BY k.ad, m.ad
        """,
        (tarif_id,),
    )
    malzemeler = cursor.fetchall()
    cursor.close()
    conn.close()

    tarif["malzemeler"] = malzemeler
    return jsonify(tarif)


if __name__ == "__main__":
    debug = os.getenv("FLASK_DEBUG", "false").lower() == "true"
    app.run(debug=debug, host="0.0.0.0", port=5000)
