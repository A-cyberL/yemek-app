# 🍽️ Yemek Tarifi Önerici

Evdeki malzemeleri girerek yapılabilecek yemek tariflerini öneren web uygulaması.

## Teknoloji Stack

| Katman | Teknoloji |
|--------|-----------|
| Frontend | Vue 3 + Vite |
| Backend | Python Flask |
| Veritabanı | MySQL |

## Özellikler

- **Malzeme Girişi** – Listeden seçin veya yazarak arayın
- **Hatalı Malzeme Engeli** – "Taş", "Kağıt" gibi geçersiz malzemeleri reddeder
- **Benzer Malzeme Önerileri** – Yanlış yazımlarda en yakın malzemeleri önerir
- **Tarif Önerisi** – Eşleşme yüzdesine göre sıralanmış tarifler
- **Eşleşme Yüzdesi** – Renkli gösterim (yeşil / sarı / kırmızı)
- **Zorluk Seviyesi** – 1–5 yıldız
- **Pişirme Süresi** – Her tarif için dakika cinsinden
- **Malzeme Kategorileri** – Sebzeler, Etler, Baharatlar vb.
- **Tarif Detayı** – Hangi malzemelerin elinizde olduğunu modal içinde gösterir
- **Responsive Tasarım** – Mobil uyumlu

## Proje Yapısı

```
yemek-app/
├── backend/
│   ├── app.py               # Flask API
│   ├── requirements.txt     # Python bağımlılıkları
│   └── database_schema.sql  # MySQL şema + örnek veriler
├── frontend/
│   ├── index.html
│   ├── package.json
│   ├── vite.config.js
│   └── src/
│       ├── main.js
│       └── App.vue          # Ana Vue bileşeni
└── README.md
```

## Kurulum

### Gereksinimler

- Python 3.9+
- Node.js 18+
- MySQL 8.0+

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

MySQL'de veritabanını oluşturun:

```bash
mysql -u root -p < database_schema.sql
```

`.env` dosyası oluşturun (isteğe bağlı, varsayılanlar localhost/root):

```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=yemek_app
```

Flask sunucusunu başlatın:

```bash
python app.py
# http://localhost:5000
```

### Frontend

```bash
cd frontend
npm install
npm run dev
# http://localhost:5173
```

## API Endpoints

| Method | Endpoint | Açıklama |
|--------|----------|----------|
| GET | `/api/malzemeler` | Tüm malzemeleri listele |
| GET | `/api/kategoriler` | Tüm kategorileri listele |
| POST | `/api/tarif-onerisi` | Malzemelere göre tarif öner |
| POST | `/api/malzeme-dogrula` | Malzeme geçerliliğini kontrol et |
| GET | `/api/tarif/<id>` | Tarif detayını getir |
