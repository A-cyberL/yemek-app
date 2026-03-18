-- Yemek Tarifi Önerici Uygulaması - Veritabanı Şeması
-- MySQL 8.0+

CREATE DATABASE IF NOT EXISTS yemek_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE yemek_app;

-- Malzeme Kategorileri
CREATE TABLE IF NOT EXISTS kategoriler (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ad VARCHAR(100) NOT NULL,
    ikon VARCHAR(10) DEFAULT '🍽️',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Malzemeler
CREATE TABLE IF NOT EXISTS malzemeler (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ad VARCHAR(100) NOT NULL UNIQUE,
    kategori_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (kategori_id) REFERENCES kategoriler(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tarifler
CREATE TABLE IF NOT EXISTS tarifler (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ad VARCHAR(200) NOT NULL,
    aciklama TEXT,
    zorluk INT NOT NULL DEFAULT 1 CHECK (zorluk BETWEEN 1 AND 5),
    pisirme_suresi INT NOT NULL DEFAULT 30 COMMENT 'dakika cinsinden',
    porsiyon INT NOT NULL DEFAULT 4,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tarif - Malzeme İlişkisi
CREATE TABLE IF NOT EXISTS tarif_malzemeleri (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tarif_id INT NOT NULL,
    malzeme_id INT NOT NULL,
    miktar VARCHAR(50),
    FOREIGN KEY (tarif_id) REFERENCES tarifler(id) ON DELETE CASCADE,
    FOREIGN KEY (malzeme_id) REFERENCES malzemeler(id) ON DELETE CASCADE,
    UNIQUE KEY (tarif_id, malzeme_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- ÖRNEK VERİLER
-- =====================================================

INSERT INTO kategoriler (ad, ikon) VALUES
('Sebzeler', '🥦'),
('Etler', '🥩'),
('Tahıllar & Baklagiller', '🌾'),
('Süt Ürünleri', '🧀'),
('Baharatlar', '🌶️'),
('Yağlar & Soslar', '🫙'),
('Meyveler', '🍎'),
('Deniz Ürünleri', '🐟');

INSERT INTO malzemeler (ad, kategori_id) VALUES
-- Sebzeler
('Domates', 1), ('Soğan', 1), ('Sarımsak', 1), ('Patates', 1),
('Biber', 1), ('Patlıcan', 1), ('Kabak', 1), ('Havuç', 1),
('Ispanak', 1), ('Fasulye', 1), ('Bezelye', 1), ('Mısır', 1),
('Brokoli', 1), ('Mantar', 1), ('Lahana', 1), ('Kereviz', 1),
-- Etler
('Tavuk', 2), ('Dana Eti', 2), ('Kıyma', 2), ('Kuzu Eti', 2),
('Sosis', 2), ('Sucuk', 2), ('Pastırma', 2), ('Hindi', 2),
-- Tahıllar & Baklagiller
('Pirinç', 3), ('Un', 3), ('Makarna', 3), ('Mercimek', 3),
('Nohut', 3), ('Bulgur', 3), ('Yulaf', 3), ('Mısır Unu', 3),
-- Süt Ürünleri
('Süt', 4), ('Peynir', 4), ('Yoğurt', 4), ('Tereyağı', 4),
('Krema', 4), ('Kaşar', 4), ('Beyaz Peynir', 4), ('Yumurta', 4),
-- Baharatlar
('Tuz', 5), ('Karabiber', 5), ('Kırmızı Biber', 5), ('Kimyon', 5),
('Zerdeçal', 5), ('Nane', 5), ('Maydanoz', 5), ('Dereotu', 5),
('Kekik', 5), ('Pul Biber', 5), ('Tarçın', 5), ('Zencefil', 5),
-- Yağlar & Soslar
('Zeytinyağı', 6), ('Ayçiçek Yağı', 6), ('Domates Sosu', 6), ('Soya Sosu', 6),
('Sirke', 6), ('Limon Suyu', 6), ('Bal', 6), ('Hardal', 6),
-- Meyveler
('Elma', 7), ('Limon', 7), ('Portakal', 7), ('Çilek', 7),
('Muz', 7), ('Üzüm', 7), ('Nar', 7), ('Kivi', 7),
-- Deniz Ürünleri
('Somon', 8), ('Ton Balığı', 8), ('Karides', 8), ('Ahtapot', 8),
('Levrek', 8), ('Çipura', 8), ('Midye', 8), ('Hamsi', 8);

INSERT INTO tarifler (ad, aciklama, zorluk, pisirme_suresi, porsiyon) VALUES
('Domates Çorbası', 'Klasik Türk domates çorbası. Nefis ve kolay yapılır.', 1, 25, 4),
('Tavuklu Pilav', 'Geleneksel tavuklu pilav tarifi. Bayram sofralarının vazgeçilmezi.', 2, 45, 6),
('Mercimek Çorbası', 'Besleyici ve lezzetli kırmızı mercimek çorbası.', 1, 30, 4),
('Karnıyarık', 'Patlıcanlı, kıymalı geleneksel Türk yemeği.', 3, 60, 4),
('Makarna Bolonez', 'Kıymalı bolonez soslu makarna.', 2, 35, 4),
('İmam Bayıldı', 'Zeytinyağlı patlıcan yemeği.', 3, 50, 4),
('Patates Kızartması', 'Çıtır çıtır patates kızartması.', 1, 20, 4),
('Tavuk Şiş', 'Marine edilmiş tavuk şiş kebap.', 2, 30, 4),
('Menemen', 'Sabahların vazgeçilmezi yumurtalı menemen.', 1, 15, 2),
('Nohutlu Pilav', 'Nohutlu ve tereyağlı pilav.', 2, 40, 6),
('Köfte', 'Izgara köfte - geleneksel tarif.', 2, 25, 4),
('Fırın Makarna', 'Peynirli fırın makarna.', 3, 45, 6),
('Sebzeli Güveç', 'Karışık sebzeli fırın güveci.', 3, 70, 4),
('Bulgur Pilavı', 'Domatesli bulgur pilavı.', 1, 25, 4),
('Somon Izgara', 'Limonlu ve sarımsaklı ızgara somon.', 2, 20, 2),
('Tavuk Sote', 'Sebzeli tavuk sote.', 2, 30, 4),
('Ispanak Yemeği', 'Pirinçli ıspanak yemeği.', 2, 35, 4),
('Lahana Sarması', 'Lahanaya sarılmış pirinçli kıyma.', 4, 90, 6),
('Patates Çorbası', 'Kremalı patates çorbası.', 2, 30, 4),
('Etli Nohut', 'Et ve nohutla yapılan doyurucu yemek.', 3, 75, 4);

INSERT INTO tarif_malzemeleri (tarif_id, malzeme_id, miktar) VALUES
-- Domates Çorbası (id=1)
(1, (SELECT id FROM malzemeler WHERE ad='Domates'), '500g'),
(1, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(1, (SELECT id FROM malzemeler WHERE ad='Tereyağı'), '2 yemek kaşığı'),
(1, (SELECT id FROM malzemeler WHERE ad='Un'), '2 yemek kaşığı'),
(1, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),
(1, (SELECT id FROM malzemeler WHERE ad='Karabiber'), 'Tatmak için'),

-- Tavuklu Pilav (id=2)
(2, (SELECT id FROM malzemeler WHERE ad='Tavuk'), '500g'),
(2, (SELECT id FROM malzemeler WHERE ad='Pirinç'), '2 su bardağı'),
(2, (SELECT id FROM malzemeler WHERE ad='Tereyağı'), '3 yemek kaşığı'),
(2, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(2, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),

-- Mercimek Çorbası (id=3)
(3, (SELECT id FROM malzemeler WHERE ad='Mercimek'), '1 su bardağı'),
(3, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(3, (SELECT id FROM malzemeler WHERE ad='Havuç'), '1 adet'),
(3, (SELECT id FROM malzemeler WHERE ad='Patates'), '1 adet'),
(3, (SELECT id FROM malzemeler WHERE ad='Zeytinyağı'), '2 yemek kaşığı'),
(3, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),
(3, (SELECT id FROM malzemeler WHERE ad='Kimyon'), '1 çay kaşığı'),

-- Karnıyarık (id=4)
(4, (SELECT id FROM malzemeler WHERE ad='Patlıcan'), '4 adet'),
(4, (SELECT id FROM malzemeler WHERE ad='Kıyma'), '300g'),
(4, (SELECT id FROM malzemeler WHERE ad='Domates'), '2 adet'),
(4, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(4, (SELECT id FROM malzemeler WHERE ad='Sarımsak'), '3 diş'),
(4, (SELECT id FROM malzemeler WHERE ad='Biber'), '2 adet'),
(4, (SELECT id FROM malzemeler WHERE ad='Ayçiçek Yağı'), '1 su bardağı'),
(4, (SELECT id FROM malzemeler WHERE ad='Maydanoz'), 'Yarım demet'),

-- Makarna Bolonez (id=5)
(5, (SELECT id FROM malzemeler WHERE ad='Makarna'), '400g'),
(5, (SELECT id FROM malzemeler WHERE ad='Kıyma'), '300g'),
(5, (SELECT id FROM malzemeler WHERE ad='Domates'), '3 adet'),
(5, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(5, (SELECT id FROM malzemeler WHERE ad='Sarımsak'), '3 diş'),
(5, (SELECT id FROM malzemeler WHERE ad='Zeytinyağı'), '2 yemek kaşığı'),
(5, (SELECT id FROM malzemeler WHERE ad='Karabiber'), 'Tatmak için'),

-- İmam Bayıldı (id=6)
(6, (SELECT id FROM malzemeler WHERE ad='Patlıcan'), '4 adet'),
(6, (SELECT id FROM malzemeler WHERE ad='Soğan'), '2 adet'),
(6, (SELECT id FROM malzemeler WHERE ad='Domates'), '3 adet'),
(6, (SELECT id FROM malzemeler WHERE ad='Sarımsak'), '4 diş'),
(6, (SELECT id FROM malzemeler WHERE ad='Zeytinyağı'), 'Yarım su bardağı'),
(6, (SELECT id FROM malzemeler WHERE ad='Maydanoz'), 'Yarım demet'),

-- Patates Kızartması (id=7)
(7, (SELECT id FROM malzemeler WHERE ad='Patates'), '4 adet'),
(7, (SELECT id FROM malzemeler WHERE ad='Ayçiçek Yağı'), '2 su bardağı'),
(7, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),

-- Tavuk Şiş (id=8)
(8, (SELECT id FROM malzemeler WHERE ad='Tavuk'), '500g'),
(8, (SELECT id FROM malzemeler WHERE ad='Yoğurt'), '2 yemek kaşığı'),
(8, (SELECT id FROM malzemeler WHERE ad='Zeytinyağı'), '2 yemek kaşığı'),
(8, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(8, (SELECT id FROM malzemeler WHERE ad='Kırmızı Biber'), '1 tatlı kaşığı'),
(8, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),

-- Menemen (id=9)
(9, (SELECT id FROM malzemeler WHERE ad='Yumurta'), '4 adet'),
(9, (SELECT id FROM malzemeler WHERE ad='Domates'), '2 adet'),
(9, (SELECT id FROM malzemeler WHERE ad='Biber'), '2 adet'),
(9, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(9, (SELECT id FROM malzemeler WHERE ad='Zeytinyağı'), '2 yemek kaşığı'),
(9, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),

-- Nohutlu Pilav (id=10)
(10, (SELECT id FROM malzemeler WHERE ad='Pirinç'), '2 su bardağı'),
(10, (SELECT id FROM malzemeler WHERE ad='Nohut'), '1 su bardağı'),
(10, (SELECT id FROM malzemeler WHERE ad='Tereyağı'), '2 yemek kaşığı'),
(10, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),

-- Köfte (id=11)
(11, (SELECT id FROM malzemeler WHERE ad='Kıyma'), '500g'),
(11, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(11, (SELECT id FROM malzemeler WHERE ad='Maydanoz'), 'Yarım demet'),
(11, (SELECT id FROM malzemeler WHERE ad='Karabiber'), '1 çay kaşığı'),
(11, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),

-- Fırın Makarna (id=12)
(12, (SELECT id FROM malzemeler WHERE ad='Makarna'), '400g'),
(12, (SELECT id FROM malzemeler WHERE ad='Kaşar'), '200g'),
(12, (SELECT id FROM malzemeler WHERE ad='Süt'), '2 su bardağı'),
(12, (SELECT id FROM malzemeler WHERE ad='Tereyağı'), '3 yemek kaşığı'),
(12, (SELECT id FROM malzemeler WHERE ad='Un'), '2 yemek kaşığı'),

-- Sebzeli Güveç (id=13)
(13, (SELECT id FROM malzemeler WHERE ad='Patates'), '2 adet'),
(13, (SELECT id FROM malzemeler WHERE ad='Havuç'), '2 adet'),
(13, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(13, (SELECT id FROM malzemeler WHERE ad='Domates'), '2 adet'),
(13, (SELECT id FROM malzemeler WHERE ad='Biber'), '2 adet'),
(13, (SELECT id FROM malzemeler WHERE ad='Kabak'), '2 adet'),
(13, (SELECT id FROM malzemeler WHERE ad='Zeytinyağı'), '3 yemek kaşığı'),
(13, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),

-- Bulgur Pilavı (id=14)
(14, (SELECT id FROM malzemeler WHERE ad='Bulgur'), '2 su bardağı'),
(14, (SELECT id FROM malzemeler WHERE ad='Domates'), '1 adet'),
(14, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(14, (SELECT id FROM malzemeler WHERE ad='Tereyağı'), '2 yemek kaşığı'),
(14, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),

-- Somon Izgara (id=15)
(15, (SELECT id FROM malzemeler WHERE ad='Somon'), '2 fileto'),
(15, (SELECT id FROM malzemeler WHERE ad='Limon'), '1 adet'),
(15, (SELECT id FROM malzemeler WHERE ad='Sarımsak'), '2 diş'),
(15, (SELECT id FROM malzemeler WHERE ad='Zeytinyağı'), '2 yemek kaşığı'),
(15, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),
(15, (SELECT id FROM malzemeler WHERE ad='Dereotu'), 'Yarım demet'),

-- Tavuk Sote (id=16)
(16, (SELECT id FROM malzemeler WHERE ad='Tavuk'), '400g'),
(16, (SELECT id FROM malzemeler WHERE ad='Biber'), '2 adet'),
(16, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(16, (SELECT id FROM malzemeler WHERE ad='Domates'), '1 adet'),
(16, (SELECT id FROM malzemeler WHERE ad='Sarımsak'), '3 diş'),
(16, (SELECT id FROM malzemeler WHERE ad='Zeytinyağı'), '2 yemek kaşığı'),
(16, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),

-- Ispanak Yemeği (id=17)
(17, (SELECT id FROM malzemeler WHERE ad='Ispanak'), '1kg'),
(17, (SELECT id FROM malzemeler WHERE ad='Pirinç'), 'Yarım su bardağı'),
(17, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(17, (SELECT id FROM malzemeler WHERE ad='Zeytinyağı'), '2 yemek kaşığı'),
(17, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),

-- Lahana Sarması (id=18)
(18, (SELECT id FROM malzemeler WHERE ad='Lahana'), '1 kafa'),
(18, (SELECT id FROM malzemeler WHERE ad='Kıyma'), '300g'),
(18, (SELECT id FROM malzemeler WHERE ad='Pirinç'), 'Yarım su bardağı'),
(18, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(18, (SELECT id FROM malzemeler WHERE ad='Domates Sosu'), '2 yemek kaşığı'),
(18, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),

-- Patates Çorbası (id=19)
(19, (SELECT id FROM malzemeler WHERE ad='Patates'), '4 adet'),
(19, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(19, (SELECT id FROM malzemeler WHERE ad='Krema'), 'Yarım su bardağı'),
(19, (SELECT id FROM malzemeler WHERE ad='Tereyağı'), '2 yemek kaşığı'),
(19, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),

-- Etli Nohut (id=20)
(20, (SELECT id FROM malzemeler WHERE ad='Dana Eti'), '400g'),
(20, (SELECT id FROM malzemeler WHERE ad='Nohut'), '1 su bardağı'),
(20, (SELECT id FROM malzemeler WHERE ad='Soğan'), '1 adet'),
(20, (SELECT id FROM malzemeler WHERE ad='Domates'), '1 adet'),
(20, (SELECT id FROM malzemeler WHERE ad='Tuz'), 'Tatmak için'),
(20, (SELECT id FROM malzemeler WHERE ad='Karabiber'), 'Tatmak için');
