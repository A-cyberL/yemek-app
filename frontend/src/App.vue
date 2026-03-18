<template>
  <div class="app">
    <!-- Header -->
    <header class="header">
      <div class="header-content">
        <span class="logo">🍽️</span>
        <div>
          <h1>Yemek Tarifi Önerici</h1>
          <p class="subtitle">Evdeki malzemeleri gir, tarifleri keşfet!</p>
        </div>
      </div>
    </header>

    <main class="main">
      <!-- Malzeme Giriş Bölümü -->
      <section class="card ingredient-section">
        <h2>🛒 Malzemelerinizi Ekleyin</h2>

        <!-- Arama / Giriş -->
        <div class="search-row">
          <input
            v-model="aramaMetni"
            @keyup.enter="malzemeEkle"
            @input="filtreliMalzemeleriGuncelle"
            placeholder="Malzeme adı yazın veya listeden seçin..."
            class="input"
          />
          <button @click="malzemeEkle" class="btn btn-primary">Ekle</button>
        </div>

        <!-- Hata / Öneri Mesajı -->
        <div v-if="hataMesaji" class="error-box">
          <p>⚠️ {{ hataMesaji }}</p>
          <div v-if="benzerOneriler.length" class="suggestions">
            <p class="suggestions-title">Belki şunu mu demek istediniz?</p>
            <button
              v-for="oneri in benzerOneriler"
              :key="oneri"
              @click="oneriSec(oneri)"
              class="suggestion-chip"
            >
              {{ oneri }}
            </button>
          </div>
        </div>

        <!-- Kategorilere göre malzeme listesi -->
        <div v-if="yukleniyor" class="loading">Malzemeler yükleniyor...</div>
        <div v-else-if="filtreliKategoriler.length" class="category-grid">
          <div v-for="kat in filtreliKategoriler" :key="kat.id" class="category-card">
            <h3>{{ kat.ikon }} {{ kat.ad }}</h3>
            <div class="chip-grid">
              <button
                v-for="malzeme in kat.malzemeler"
                :key="malzeme.id"
                @click="malzemeToggle(malzeme.ad)"
                :class="['chip', { 'chip-selected': seciliMalzemeler.includes(malzeme.ad) }]"
              >
                {{ malzeme.ad }}
                <span v-if="seciliMalzemeler.includes(malzeme.ad)">✓</span>
              </button>
            </div>
          </div>
        </div>

        <!-- Seçili malzemeler -->
        <div v-if="seciliMalzemeler.length" class="selected-section">
          <h3>✅ Seçili Malzemeler ({{ seciliMalzemeler.length }})</h3>
          <div class="selected-chips">
            <span
              v-for="malzeme in seciliMalzemeler"
              :key="malzeme"
              class="selected-chip"
            >
              {{ malzeme }}
              <button @click="malzemeCikar(malzeme)" class="remove-btn">×</button>
            </span>
          </div>
          <div class="action-row">
            <button @click="tarifOner" class="btn btn-success" :disabled="tarifYukleniyor">
              {{ tarifYukleniyor ? '🔍 Aranıyor...' : '🍴 Tarif Bul' }}
            </button>
            <button @click="temizle" class="btn btn-secondary">Temizle</button>
          </div>
        </div>
      </section>

      <!-- Tarif Sonuçları -->
      <section v-if="tarifSonuclari !== null" class="card results-section">
        <h2>🍴 Tarif Önerileri</h2>

        <div v-if="tarifSonuclari.length === 0" class="no-results">
          <p>😔 Seçili malzemelerle eşleşen tarif bulunamadı.</p>
          <p>Daha fazla malzeme eklemeyi deneyin.</p>
        </div>

        <div v-else class="recipe-grid">
          <div
            v-for="tarif in tarifSonuclari"
            :key="tarif.id"
            class="recipe-card"
            @click="tarifDetayGoster(tarif)"
          >
            <!-- Eşleşme yüzdesi -->
            <div :class="['match-badge', matchRengi(tarif.eslesme_yuzdesi)]">
              {{ tarif.eslesme_yuzdesi }}% Eşleşme
            </div>

            <h3 class="recipe-title">{{ tarif.ad }}</h3>
            <p class="recipe-desc">{{ tarif.aciklama }}</p>

            <div class="recipe-meta">
              <!-- Zorluk (yıldız) -->
              <span class="meta-item">
                <span class="stars">
                  <span v-for="n in 5" :key="n" :class="n <= tarif.zorluk ? 'star filled' : 'star'">★</span>
                </span>
                <span class="meta-label">Zorluk</span>
              </span>

              <!-- Pişirme süresi -->
              <span class="meta-item">
                <span class="meta-icon">⏱️</span>
                <span>{{ tarif.pisirme_suresi }} dk</span>
              </span>

              <!-- Porsiyon -->
              <span class="meta-item">
                <span class="meta-icon">👥</span>
                <span>{{ tarif.porsiyon }} kişilik</span>
              </span>
            </div>

            <!-- Eşleşen / toplam malzeme -->
            <div class="ingredient-count">
              <div
                class="progress-bar"
                :style="{ width: tarif.eslesme_yuzdesi + '%' }"
                :class="matchRengi(tarif.eslesme_yuzdesi)"
              ></div>
              <span>{{ tarif.eslesen_malzeme_sayisi }} / {{ tarif.toplam_malzeme_sayisi }} malzeme elinizde</span>
            </div>

            <p class="details-hint">Detaylar için tıklayın →</p>
          </div>
        </div>
      </section>
    </main>

    <!-- Tarif Detay Modal -->
    <div v-if="secilenTarif" class="modal-overlay" @click.self="modalKapat">
      <div class="modal">
        <button class="modal-close" @click="modalKapat">×</button>

        <div :class="['match-badge', matchRengi(secilenTarif.eslesme_yuzdesi)]" style="display:inline-block;margin-bottom:12px">
          {{ secilenTarif.eslesme_yuzdesi }}% Eşleşme
        </div>

        <h2>{{ secilenTarif.ad }}</h2>
        <p class="recipe-desc">{{ secilenTarif.aciklama }}</p>

        <div class="recipe-meta" style="margin:16px 0">
          <span class="meta-item">
            <span class="stars">
              <span v-for="n in 5" :key="n" :class="n <= secilenTarif.zorluk ? 'star filled' : 'star'">★</span>
            </span>
          </span>
          <span class="meta-item">⏱️ {{ secilenTarif.pisirme_suresi }} dakika</span>
          <span class="meta-item">👥 {{ secilenTarif.porsiyon }} kişilik</span>
        </div>

        <h3>📋 Malzemeler</h3>
        <ul class="ingredient-list">
          <li
            v-for="m in secilenTarif.tum_malzemeler"
            :key="m.ad"
            :class="{ 'have-it': secilenTarif.eslesen_malzemeler.includes(m.ad.toLowerCase()) }"
          >
            <span class="ing-indicator">
              {{ secilenTarif.eslesen_malzemeler.includes(m.ad.toLowerCase()) ? '✅' : '❌' }}
            </span>
            <strong>{{ m.ad }}</strong>
            <span v-if="m.miktar" class="ing-amount"> – {{ m.miktar }}</span>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const API = '/api'

// State
const aramaMetni = ref('')
const seciliMalzemeler = ref([])
const kategoriler = ref([])
const yukleniyor = ref(true)
const hataMesaji = ref('')
const benzerOneriler = ref([])
const tarifSonuclari = ref(null)
const tarifYukleniyor = ref(false)
const secilenTarif = ref(null)

// Kategorileri yükle
onMounted(async () => {
  try {
    const [katRes, malRes] = await Promise.all([
      fetch(`${API}/kategoriler`),
      fetch(`${API}/malzemeler`),
    ])
    const katData = await katRes.json()
    const malData = await malRes.json()

    kategoriler.value = katData.map(k => ({
      ...k,
      malzemeler: malData.filter(m => m.kategori_id === k.id),
    }))
  } catch (e) {
    console.error('Veriler yüklenemedi:', e)
  } finally {
    yukleniyor.value = false
  }
})

// Filtrelenmiş kategoriler (arama metnine göre)
const filtreliKategoriler = computed(() => {
  if (!aramaMetni.value.trim()) return kategoriler.value
  const q = aramaMetni.value.toLowerCase()
  return kategoriler.value
    .map(k => ({
      ...k,
      malzemeler: k.malzemeler.filter(m => m.ad.toLowerCase().includes(q)),
    }))
    .filter(k => k.malzemeler.length > 0)
})

function filtreliMalzemeleriGuncelle() {
  hataMesaji.value = ''
  benzerOneriler.value = []
}

// Malzeme toggle (listeden tıklama)
function malzemeToggle(ad) {
  if (seciliMalzemeler.value.includes(ad)) {
    malzemeCikar(ad)
  } else {
    seciliMalzemeler.value.push(ad)
    aramaMetni.value = ''
    hataMesaji.value = ''
    benzerOneriler.value = []
  }
}

// Input ile malzeme ekle (doğrulama ile)
async function malzemeEkle() {
  const girilen = aramaMetni.value.trim()
  if (!girilen) return

  // Önce listede doğrula
  try {
    const res = await fetch(`${API}/malzeme-dogrula`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ malzeme: girilen }),
    })
    const data = await res.json()

    if (data.gecerli) {
      if (!seciliMalzemeler.value.includes(data.malzeme)) {
        seciliMalzemeler.value.push(data.malzeme)
      }
      aramaMetni.value = ''
      hataMesaji.value = ''
      benzerOneriler.value = []
    } else {
      hataMesaji.value = data.mesaj
      benzerOneriler.value = data.oneriler || []
    }
  } catch (e) {
    hataMesaji.value = 'Sunucuya bağlanılamadı.'
  }
}

// Öneri chip'ine tıklandığında
function oneriSec(ad) {
  if (!seciliMalzemeler.value.includes(ad)) {
    seciliMalzemeler.value.push(ad)
  }
  aramaMetni.value = ''
  hataMesaji.value = ''
  benzerOneriler.value = []
}

function malzemeCikar(ad) {
  seciliMalzemeler.value = seciliMalzemeler.value.filter(m => m !== ad)
}

function temizle() {
  seciliMalzemeler.value = []
  tarifSonuclari.value = null
  hataMesaji.value = ''
  benzerOneriler.value = []
  aramaMetni.value = ''
}

// Tarif öner
async function tarifOner() {
  if (!seciliMalzemeler.value.length) return
  tarifYukleniyor.value = true
  try {
    const res = await fetch(`${API}/tarif-onerisi`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ malzemeler: seciliMalzemeler.value }),
    })
    tarifSonuclari.value = await res.json()
  } catch (e) {
    tarifSonuclari.value = []
  } finally {
    tarifYukleniyor.value = false
  }
}

function tarifDetayGoster(tarif) {
  secilenTarif.value = tarif
}

function modalKapat() {
  secilenTarif.value = null
}

// Renk sınıfı eşleşme yüzdesine göre
function matchRengi(yuzde) {
  if (yuzde >= 75) return 'match-high'
  if (yuzde >= 40) return 'match-mid'
  return 'match-low'
}
</script>

<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: 'Segoe UI', system-ui, sans-serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  min-height: 100vh;
  color: #1a202c;
}

/* ---- Header ---- */
.header {
  background: rgba(255,255,255,0.15);
  backdrop-filter: blur(10px);
  padding: 20px 24px;
  color: white;
  box-shadow: 0 2px 20px rgba(0,0,0,0.1);
}
.header-content { display: flex; align-items: center; gap: 16px; max-width: 1100px; margin: 0 auto; }
.logo { font-size: 2.5rem; }
.header h1 { font-size: 1.8rem; font-weight: 700; }
.subtitle { opacity: 0.85; font-size: 0.95rem; }

/* ---- Main ---- */
.main { max-width: 1100px; margin: 32px auto; padding: 0 16px; display: flex; flex-direction: column; gap: 24px; }

/* ---- Card ---- */
.card {
  background: white;
  border-radius: 16px;
  padding: 28px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.12);
}
.card h2 { font-size: 1.4rem; margin-bottom: 20px; color: #2d3748; }

/* ---- Inputs ---- */
.search-row { display: flex; gap: 12px; margin-bottom: 16px; }
.input {
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  font-size: 1rem;
  transition: border-color 0.2s;
  outline: none;
}
.input:focus { border-color: #667eea; }

/* ---- Buttons ---- */
.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.15s, opacity 0.15s;
}
.btn:hover:not(:disabled) { transform: translateY(-1px); }
.btn:disabled { opacity: 0.6; cursor: not-allowed; }
.btn-primary { background: linear-gradient(135deg, #667eea, #764ba2); color: white; }
.btn-success { background: linear-gradient(135deg, #48bb78, #38a169); color: white; }
.btn-secondary { background: #e2e8f0; color: #4a5568; }

/* ---- Error / Suggestions ---- */
.error-box {
  background: #fff5f5;
  border: 1px solid #fed7d7;
  border-radius: 10px;
  padding: 14px 18px;
  margin-bottom: 16px;
  color: #c53030;
}
.suggestions { margin-top: 10px; }
.suggestions-title { font-size: 0.85rem; color: #718096; margin-bottom: 8px; }
.suggestion-chip {
  display: inline-block;
  margin: 4px;
  padding: 6px 14px;
  background: #ebf8ff;
  border: 1px solid #bee3f8;
  border-radius: 20px;
  color: #2b6cb0;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background 0.15s;
}
.suggestion-chip:hover { background: #bee3f8; }

/* ---- Category Grid ---- */
.category-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 20px; margin-bottom: 24px; }
.category-card { background: #f7fafc; border-radius: 12px; padding: 16px; }
.category-card h3 { font-size: 0.95rem; color: #4a5568; margin-bottom: 12px; }

/* ---- Chips ---- */
.chip-grid { display: flex; flex-wrap: wrap; gap: 6px; }
.chip {
  padding: 5px 12px;
  border: 1.5px solid #e2e8f0;
  border-radius: 20px;
  background: white;
  font-size: 0.82rem;
  cursor: pointer;
  transition: all 0.15s;
  color: #4a5568;
  display: flex; align-items: center; gap: 4px;
}
.chip:hover { border-color: #667eea; color: #667eea; }
.chip-selected { background: #667eea; border-color: #667eea; color: white; }

/* ---- Selected ---- */
.selected-section { border-top: 1px solid #e2e8f0; padding-top: 20px; margin-top: 4px; }
.selected-section h3 { margin-bottom: 12px; color: #2d3748; }
.selected-chips { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 20px; }
.selected-chip {
  display: flex; align-items: center; gap: 6px;
  padding: 6px 14px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border-radius: 20px;
  font-size: 0.9rem;
}
.remove-btn { background: none; border: none; color: white; font-size: 1.1rem; cursor: pointer; line-height: 1; padding: 0; margin-left: 2px; }
.action-row { display: flex; gap: 12px; flex-wrap: wrap; }

/* ---- Loading ---- */
.loading { text-align: center; padding: 24px; color: #718096; }

/* ---- No Results ---- */
.no-results { text-align: center; padding: 32px; color: #718096; }
.no-results p { margin-bottom: 8px; }

/* ---- Recipe Grid ---- */
.recipe-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; }
.recipe-card {
  border: 1.5px solid #e2e8f0;
  border-radius: 14px;
  padding: 20px;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  position: relative;
  overflow: hidden;
}
.recipe-card:hover { transform: translateY(-3px); box-shadow: 0 12px 30px rgba(0,0,0,0.12); }

/* ---- Match Badge ---- */
.match-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.82rem;
  font-weight: 700;
  margin-bottom: 10px;
}
.match-high { background: #c6f6d5; color: #276749; }
.match-mid  { background: #fefcbf; color: #7b6002; }
.match-low  { background: #fed7d7; color: #9b2c2c; }

.recipe-title { font-size: 1.1rem; font-weight: 700; margin-bottom: 6px; color: #2d3748; }
.recipe-desc { font-size: 0.85rem; color: #718096; margin-bottom: 14px; line-height: 1.5; }

/* ---- Meta ---- */
.recipe-meta { display: flex; gap: 16px; flex-wrap: wrap; align-items: center; margin-bottom: 14px; font-size: 0.88rem; color: #4a5568; }
.meta-item { display: flex; align-items: center; gap: 4px; }
.meta-icon { font-size: 1rem; }
.meta-label { font-size: 0.78rem; color: #a0aec0; margin-left: 2px; }

/* ---- Stars ---- */
.stars { display: inline-flex; gap: 1px; }
.star { color: #e2e8f0; font-size: 1rem; }
.star.filled { color: #f6ad55; }

/* ---- Progress Bar ---- */
.ingredient-count { position: relative; background: #edf2f7; border-radius: 6px; height: 6px; margin-bottom: 8px; overflow: hidden; }
.progress-bar { height: 100%; border-radius: 6px; transition: width 0.4s; }
.progress-bar.match-high { background: #48bb78; }
.progress-bar.match-mid  { background: #ecc94b; }
.progress-bar.match-low  { background: #fc8181; }
.ingredient-count span { display: block; font-size: 0.78rem; color: #718096; margin-top: 6px; }

.details-hint { font-size: 0.78rem; color: #a0aec0; text-align: right; margin-top: 4px; }

/* ---- Modal ---- */
.modal-overlay {
  position: fixed; inset: 0;
  background: rgba(0,0,0,0.5);
  display: flex; align-items: center; justify-content: center;
  z-index: 100;
  padding: 16px;
}
.modal {
  background: white;
  border-radius: 16px;
  padding: 32px;
  max-width: 540px;
  width: 100%;
  max-height: 80vh;
  overflow-y: auto;
  position: relative;
}
.modal h2 { font-size: 1.4rem; margin-bottom: 8px; color: #2d3748; }
.modal h3 { margin: 20px 0 12px; color: #2d3748; }
.modal-close {
  position: absolute; top: 16px; right: 16px;
  background: none; border: none; font-size: 1.6rem; cursor: pointer; color: #718096; line-height: 1;
}
.modal-close:hover { color: #2d3748; }

/* ---- Ingredient List ---- */
.ingredient-list { list-style: none; display: flex; flex-direction: column; gap: 8px; }
.ingredient-list li {
  display: flex; align-items: center; gap: 8px;
  padding: 10px 14px;
  border-radius: 8px;
  background: #f7fafc;
  font-size: 0.9rem;
}
.ingredient-list li.have-it { background: #f0fff4; }
.ing-amount { color: #718096; }

/* ---- Responsive ---- */
@media (max-width: 640px) {
  .header h1 { font-size: 1.3rem; }
  .logo { font-size: 2rem; }
  .card { padding: 18px; }
  .search-row { flex-direction: column; }
  .btn { width: 100%; text-align: center; }
  .recipe-grid { grid-template-columns: 1fr; }
  .category-grid { grid-template-columns: 1fr; }
  .action-row { flex-direction: column; }
}
</style>
