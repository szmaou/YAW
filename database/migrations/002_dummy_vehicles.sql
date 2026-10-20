-- 002_dummy_vehicles.sql — seed data kendaraan dummy (12 unit + kategori MPV/City Car).
-- Dijalankan SEKALI saat start pertama oleh initDb (marker di schema_migrations),
-- sehingga aman dijalankan berulang dan aman jika dihapus manual:
--   undo: DELETE FROM vehicles WHERE slug IN (... daftar slug di bawah);
--         HAPUS juga baris '002_dummy_vehicles' di schema_migrations bila ingin di-seed lagi.
-- Foto = foto model asli masing-masing kendaraan (Wikimedia Commons, URL thumbnail 1280px).

CREATE TABLE IF NOT EXISTS schema_migrations (
  name VARCHAR(120) PRIMARY KEY,
  applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- ---- Kategori tambahan (idempoten) ----
INSERT INTO vehicle_categories (name, slug, description)
SELECT 'MPV', 'mpv', 'Multi Purpose Vehicle'
WHERE NOT EXISTS (SELECT 1 FROM vehicle_categories WHERE slug = 'mpv');
INSERT INTO vehicle_categories (name, slug, description)
SELECT 'City Car', 'city-car', 'Kendaraan kompak perkotaan'
WHERE NOT EXISTS (SELECT 1 FROM vehicle_categories WHERE slug = 'city-car');


-- ---- Toyota Fortuner 2.4 VRZ ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Toyota Fortuner 2.4 VRZ', 'toyota-fortuner-2-4-vrz', 'Toyota', 'Fortuner 2.4 VRZ', 2024, 570000000, 5, 'SUV 7-penumpang tahan segala medan — pilihan utama keluarga besar yang aktif.', '2.4L 2GD-FTV Turbo Diesel', 'AT', 'Diesel', 'Precious White', 1, NOW() - INTERVAL 1 DAY
FROM vehicle_categories c
WHERE c.slug = 'suv'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'toyota-fortuner-2-4-vrz');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bf/Toyota_Fortuner_4x4_Legender_2023_%283%29.jpg/1280px-Toyota_Fortuner_4x4_Legender_2023_%283%29.jpg', 1
FROM vehicles v
WHERE v.slug = 'toyota-fortuner-2-4-vrz'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bf/Toyota_Fortuner_4x4_Legender_2023_%283%29.jpg/1280px-Toyota_Fortuner_4x4_Legender_2023_%283%29.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/81/Toyota_Fortuner_4x2_Legender_2023_%2812%29.jpg/1280px-Toyota_Fortuner_4x2_Legender_2023_%2812%29.jpg', 0
FROM vehicles v
WHERE v.slug = 'toyota-fortuner-2-4-vrz'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/81/Toyota_Fortuner_4x2_Legender_2023_%2812%29.jpg/1280px-Toyota_Fortuner_4x2_Legender_2023_%2812%29.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c7/Toyota_Fortuner_SRV_2023.jpg/1280px-Toyota_Fortuner_SRV_2023.jpg', 0
FROM vehicles v
WHERE v.slug = 'toyota-fortuner-2-4-vrz'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c7/Toyota_Fortuner_SRV_2023.jpg/1280px-Toyota_Fortuner_SRV_2023.jpg');

-- ---- Toyota Corolla Cross 1.8 HEV ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Toyota Corolla Cross 1.8 HEV', 'toyota-corolla-cross-1-8-hev', 'Toyota', 'Corolla Cross 1.8 HEV', 2024, 500000000, 6, 'SUV hybrid efisien dengan konsumsi BBM rendah dan fitur lengkap di kelasnya.', '1.8L Hybrid', 'e-CVT', 'Hybrid', 'Blue Metallic', 1, NOW() - INTERVAL 2 DAY
FROM vehicle_categories c
WHERE c.slug = 'electric'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'toyota-corolla-cross-1-8-hev');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3f/Toyota_Corolla_Cross_Hybrid_1X7A6284.jpg/1280px-Toyota_Corolla_Cross_Hybrid_1X7A6284.jpg', 1
FROM vehicles v
WHERE v.slug = 'toyota-corolla-cross-1-8-hev'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3f/Toyota_Corolla_Cross_Hybrid_1X7A6284.jpg/1280px-Toyota_Corolla_Cross_Hybrid_1X7A6284.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2b/Toyota_Corolla_Cross_Hybrid_1X7A6348.jpg/1280px-Toyota_Corolla_Cross_Hybrid_1X7A6348.jpg', 0
FROM vehicles v
WHERE v.slug = 'toyota-corolla-cross-1-8-hev'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2b/Toyota_Corolla_Cross_Hybrid_1X7A6348.jpg/1280px-Toyota_Corolla_Cross_Hybrid_1X7A6348.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9c/Toyota_Corolla_Cross_Hybrid_1X7A6286.jpg/1280px-Toyota_Corolla_Cross_Hybrid_1X7A6286.jpg', 0
FROM vehicles v
WHERE v.slug = 'toyota-corolla-cross-1-8-hev'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9c/Toyota_Corolla_Cross_Hybrid_1X7A6286.jpg/1280px-Toyota_Corolla_Cross_Hybrid_1X7A6286.jpg');

-- ---- Toyota Avanza 1.5 G ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Toyota Avanza 1.5 G', 'toyota-avanza-1-5-g', 'Toyota', 'Avanza 1.5 G CVT', 2023, 245000000, 8, 'MPV keluarga terlaris di Indonesia. Tampil segar dan hemat bahan bakar.', '1.5L 2NR-VE', 'CVT', 'Bensin', 'Silver Metallic', 1, NOW() - INTERVAL 3 DAY
FROM vehicle_categories c
WHERE c.slug = 'mpv'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'toyota-avanza-1-5-g');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/25/2022_Toyota_Avanza_%28W100%29_1.5_G%2C_IIMS_Hybrid%2C_Grand_City%2C_Central_Surabaya.jpg/1280px-2022_Toyota_Avanza_%28W100%29_1.5_G%2C_IIMS_Hybrid%2C_Grand_City%2C_Central_Surabaya.jpg', 1
FROM vehicles v
WHERE v.slug = 'toyota-avanza-1-5-g'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/2/25/2022_Toyota_Avanza_%28W100%29_1.5_G%2C_IIMS_Hybrid%2C_Grand_City%2C_Central_Surabaya.jpg/1280px-2022_Toyota_Avanza_%28W100%29_1.5_G%2C_IIMS_Hybrid%2C_Grand_City%2C_Central_Surabaya.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5d/Toyota_Avanza_1.5_G_2022.jpg/1280px-Toyota_Avanza_1.5_G_2022.jpg', 0
FROM vehicles v
WHERE v.slug = 'toyota-avanza-1-5-g'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5d/Toyota_Avanza_1.5_G_2022.jpg/1280px-Toyota_Avanza_1.5_G_2022.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b9/2022_Toyota_Avanza_%28W100%29_1.5_G%2C_Pakuwon_Trade_Center%2C_West_Surabaya.jpg/1280px-2022_Toyota_Avanza_%28W100%29_1.5_G%2C_Pakuwon_Trade_Center%2C_West_Surabaya.jpg', 0
FROM vehicles v
WHERE v.slug = 'toyota-avanza-1-5-g'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b9/2022_Toyota_Avanza_%28W100%29_1.5_G%2C_Pakuwon_Trade_Center%2C_West_Surabaya.jpg/1280px-2022_Toyota_Avanza_%28W100%29_1.5_G%2C_Pakuwon_Trade_Center%2C_West_Surabaya.jpg');

-- ---- Honda BR-V Prestige ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Honda BR-V Prestige', 'honda-brv-prestige', 'Honda', 'BR-V Prestige CVT', 2023, 305000000, 9, 'SUV 7-penumpang desain modern, kabin lega untuk keluarga.', '1.5L DOHC i-VTEC', 'CVT', 'Bensin', 'Platinum White', 1, NOW() - INTERVAL 4 DAY
FROM vehicle_categories c
WHERE c.slug = 'suv'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'honda-brv-prestige');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1f/2022_Honda_BR-V_Prestige_with_Honda_Sensing_%28Indonesia%29_front_view_02.jpg/1280px-2022_Honda_BR-V_Prestige_with_Honda_Sensing_%28Indonesia%29_front_view_02.jpg', 1
FROM vehicles v
WHERE v.slug = 'honda-brv-prestige'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1f/2022_Honda_BR-V_Prestige_with_Honda_Sensing_%28Indonesia%29_front_view_02.jpg/1280px-2022_Honda_BR-V_Prestige_with_Honda_Sensing_%28Indonesia%29_front_view_02.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/6e/2022_Honda_BR-V_EL.jpg/1280px-2022_Honda_BR-V_EL.jpg', 0
FROM vehicles v
WHERE v.slug = 'honda-brv-prestige'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/6e/2022_Honda_BR-V_EL.jpg/1280px-2022_Honda_BR-V_EL.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/be/2022_Honda_BR-V_EL_%28Rear%29.jpg/1280px-2022_Honda_BR-V_EL_%28Rear%29.jpg', 0
FROM vehicles v
WHERE v.slug = 'honda-brv-prestige'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/be/2022_Honda_BR-V_EL_%28Rear%29.jpg/1280px-2022_Honda_BR-V_EL_%28Rear%29.jpg');

-- ---- Mitsubishi Xpander Ultimate ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Mitsubishi Xpander Ultimate', 'mitsubishi-xpander-ultimate', 'Mitsubishi', 'Xpander Ultimate', 2023, 290000000, 7, 'MPV desain Dynamic Shield dengan ruang kabin lega. Favorit keluarga muda.', '1.5L MIVEC', 'AT', 'Bensin', 'Metallic White', 1, NOW() - INTERVAL 5 DAY
FROM vehicle_categories c
WHERE c.slug = 'mpv'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'mitsubishi-xpander-ultimate');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/dd/2022_Mitsubishi_Xpander_Sport_facelift_%28front%29%2C_Pakuwon_Trade_Center%2C_West_Surabaya.jpg/1280px-2022_Mitsubishi_Xpander_Sport_facelift_%28front%29%2C_Pakuwon_Trade_Center%2C_West_Surabaya.jpg', 1
FROM vehicles v
WHERE v.slug = 'mitsubishi-xpander-ultimate'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/dd/2022_Mitsubishi_Xpander_Sport_facelift_%28front%29%2C_Pakuwon_Trade_Center%2C_West_Surabaya.jpg/1280px-2022_Mitsubishi_Xpander_Sport_facelift_%28front%29%2C_Pakuwon_Trade_Center%2C_West_Surabaya.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8a/2022_Mitsubishi_Xpander_Sport_facelift_%28rear%29%2C_Pakuwon_Trade_Center%2C_West_Surabaya.jpg/1280px-2022_Mitsubishi_Xpander_Sport_facelift_%28rear%29%2C_Pakuwon_Trade_Center%2C_West_Surabaya.jpg', 0
FROM vehicles v
WHERE v.slug = 'mitsubishi-xpander-ultimate'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8a/2022_Mitsubishi_Xpander_Sport_facelift_%28rear%29%2C_Pakuwon_Trade_Center%2C_West_Surabaya.jpg/1280px-2022_Mitsubishi_Xpander_Sport_facelift_%28rear%29%2C_Pakuwon_Trade_Center%2C_West_Surabaya.jpg');

-- ---- Honda Brio Satya E ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Honda Brio Satya E', 'honda-brio-satya-e-cvt', 'Honda', 'Brio Satya E CVT', 2023, 160000000, 12, 'City car populer, ideal sebagai mobil pertama. Sangat irit bensin.', '1.2L 3EA5', 'CVT', 'Bensin', 'Rallye Red', 1, NOW() - INTERVAL 6 DAY
FROM vehicle_categories c
WHERE c.slug = 'city-car'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'honda-brio-satya-e-cvt');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/73/2020_Honda_Brio_Satya_E_1.2_DD1_%2820220409%29_02.jpg/1280px-2020_Honda_Brio_Satya_E_1.2_DD1_%2820220409%29_02.jpg', 1
FROM vehicles v
WHERE v.slug = 'honda-brio-satya-e-cvt'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/73/2020_Honda_Brio_Satya_E_1.2_DD1_%2820220409%29_02.jpg/1280px-2020_Honda_Brio_Satya_E_1.2_DD1_%2820220409%29_02.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/75/2020_Honda_Brio_Satya_E_1.2_DD1_%2820220409%29_01.jpg/1280px-2020_Honda_Brio_Satya_E_1.2_DD1_%2820220409%29_01.jpg', 0
FROM vehicles v
WHERE v.slug = 'honda-brio-satya-e-cvt'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/75/2020_Honda_Brio_Satya_E_1.2_DD1_%2820220409%29_01.jpg/1280px-2020_Honda_Brio_Satya_E_1.2_DD1_%2820220409%29_01.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0c/2022_Honda_Brio.jpg/1280px-2022_Honda_Brio.jpg', 0
FROM vehicles v
WHERE v.slug = 'honda-brio-satya-e-cvt'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0c/2022_Honda_Brio.jpg/1280px-2022_Honda_Brio.jpg');

-- ---- Toyota Kijang Innova 2.0 G ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Toyota Kijang Innova 2.0 G', 'toyota-kijang-innova-2-0-g', 'Toyota', 'Kijang Innova 2.0 G', 2023, 390000000, 6, 'Keseimbangan kenyamanan dan kepraktisan untuk keluarga.', '2.0L Dual VVT-i', 'CVT', 'Bensin', 'Attitude Black', 1, NOW() - INTERVAL 7 DAY
FROM vehicle_categories c
WHERE c.slug = 'mpv'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'toyota-kijang-innova-2-0-g');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://upload.wikimedia.org/wikipedia/commons/9/90/2023_Kijang_Innova_Zenix_G_HV.jpg', 1
FROM vehicles v
WHERE v.slug = 'toyota-kijang-innova-2-0-g'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://upload.wikimedia.org/wikipedia/commons/9/90/2023_Kijang_Innova_Zenix_G_HV.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/15/2022_Toyota_Kijang_Innova_Zenix_V_%28Indonesia%29_front_view.jpg/1280px-2022_Toyota_Kijang_Innova_Zenix_V_%28Indonesia%29_front_view.jpg', 0
FROM vehicles v
WHERE v.slug = 'toyota-kijang-innova-2-0-g'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/15/2022_Toyota_Kijang_Innova_Zenix_V_%28Indonesia%29_front_view.jpg/1280px-2022_Toyota_Kijang_Innova_Zenix_V_%28Indonesia%29_front_view.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://upload.wikimedia.org/wikipedia/commons/1/1f/Kijang_Innova_Zenix_2.0_V_Gasoline.jpg', 0
FROM vehicles v
WHERE v.slug = 'toyota-kijang-innova-2-0-g'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://upload.wikimedia.org/wikipedia/commons/1/1f/Kijang_Innova_Zenix_2.0_V_Gasoline.jpg');

-- ---- Toyota GR86 2.4 ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Toyota GR86 2.4', 'toyota-gr86-2-4', 'Toyota', 'GR86 2.4 Boxer', 2023, 660000000, 3, 'Sport coupe bermesin boxer yang seru dikendarai.', '2.4L FA24 Boxer', '6MT', 'Bensin', 'Ignition Red', 1, NOW() - INTERVAL 8 DAY
FROM vehicle_categories c
WHERE c.slug = 'sports'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'toyota-gr86-2-4');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/39/Toyota_GR86_IMG_7863.jpg/1280px-Toyota_GR86_IMG_7863.jpg', 1
FROM vehicles v
WHERE v.slug = 'toyota-gr86-2-4'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/39/Toyota_GR86_IMG_7863.jpg/1280px-Toyota_GR86_IMG_7863.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/94/Toyota_GR86_Auto_Zuerich_2023_1X7A1230.jpg/1280px-Toyota_GR86_Auto_Zuerich_2023_1X7A1230.jpg', 0
FROM vehicles v
WHERE v.slug = 'toyota-gr86-2-4'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/94/Toyota_GR86_Auto_Zuerich_2023_1X7A1230.jpg/1280px-Toyota_GR86_Auto_Zuerich_2023_1X7A1230.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/93/Toyota_GR86_Auto_Zuerich_2023_1X7A1406.jpg/1280px-Toyota_GR86_Auto_Zuerich_2023_1X7A1406.jpg', 0
FROM vehicles v
WHERE v.slug = 'toyota-gr86-2-4'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/93/Toyota_GR86_Auto_Zuerich_2023_1X7A1406.jpg/1280px-Toyota_GR86_Auto_Zuerich_2023_1X7A1406.jpg');

-- ---- Wuling Air EV Long Range ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Wuling Air EV Long Range', 'wuling-air-ev-long-range', 'Wuling', 'Air EV Long Range', 2023, 215000000, 9, 'Hatchback listrik kompak untuk mobilitas kota sehari-hari.', 'Motor Listrik 65 kW', 'Single-Speed', 'Listrik', 'Aurora Silver', 1, NOW() - INTERVAL 9 DAY
FROM vehicle_categories c
WHERE c.slug = 'electric'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'wuling-air-ev-long-range');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1b/Wuling_Air_EV_IMG001.jpg/1280px-Wuling_Air_EV_IMG001.jpg', 1
FROM vehicles v
WHERE v.slug = 'wuling-air-ev-long-range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1b/Wuling_Air_EV_IMG001.jpg/1280px-Wuling_Air_EV_IMG001.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/e/ee/Wuling_Air_EV_IMG002.jpg/1280px-Wuling_Air_EV_IMG002.jpg', 0
FROM vehicles v
WHERE v.slug = 'wuling-air-ev-long-range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/e/ee/Wuling_Air_EV_IMG002.jpg/1280px-Wuling_Air_EV_IMG002.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d3/Wuling_Air_EV_IMG003.jpg/1280px-Wuling_Air_EV_IMG003.jpg', 0
FROM vehicles v
WHERE v.slug = 'wuling-air-ev-long-range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d3/Wuling_Air_EV_IMG003.jpg/1280px-Wuling_Air_EV_IMG003.jpg');

-- ---- Mitsubishi Pajero Sport Dakar ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Mitsubishi Pajero Sport Dakar', 'mitsubishi-pajero-sport-dakar', 'Mitsubishi', 'Pajero Sport Dakar 4x4', 2022, 480000000, 4, 'SUV 4x4 tahan banting untuk petualangan keluarga di segala medan.', '2.4L 4N15 8AT', '8AT', 'Diesel', 'Ferro Black', 1, NOW() - INTERVAL 10 DAY
FROM vehicle_categories c
WHERE c.slug = 'suv'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'mitsubishi-pajero-sport-dakar');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/91/2021_Mitsubishi_Pajero_Sport_%28facelift%29.jpg/1280px-2021_Mitsubishi_Pajero_Sport_%28facelift%29.jpg', 1
FROM vehicles v
WHERE v.slug = 'mitsubishi-pajero-sport-dakar'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/91/2021_Mitsubishi_Pajero_Sport_%28facelift%29.jpg/1280px-2021_Mitsubishi_Pajero_Sport_%28facelift%29.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a8/2442cc_2021_Mitsubishi_Pajero_Sport_facelift.jpg/1280px-2442cc_2021_Mitsubishi_Pajero_Sport_facelift.jpg', 0
FROM vehicles v
WHERE v.slug = 'mitsubishi-pajero-sport-dakar'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a8/2442cc_2021_Mitsubishi_Pajero_Sport_facelift.jpg/1280px-2442cc_2021_Mitsubishi_Pajero_Sport_facelift.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/74/MITSUBISHI_PAJERO_SPORT_EXTERIOR_China%281%29.jpg/1280px-MITSUBISHI_PAJERO_SPORT_EXTERIOR_China%281%29.jpg', 0
FROM vehicles v
WHERE v.slug = 'mitsubishi-pajero-sport-dakar'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/74/MITSUBISHI_PAJERO_SPORT_EXTERIOR_China%281%29.jpg/1280px-MITSUBISHI_PAJERO_SPORT_EXTERIOR_China%281%29.jpg');

-- ---- Honda Civic RS 1.5 Turbo ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Honda Civic RS 1.5 Turbo', 'honda-civic-rs-1-5-turbo', 'Honda', 'Civic RS 1.5 VTEC Turbo', 2022, 510000000, 4, 'Sedan sport bermesin turbo. Perpaduan performa dan kenyamanan.', '1.5L VTEC Turbo', 'CVT', 'Bensin', 'Sonic Grey Pearl', 1, NOW() - INTERVAL 11 DAY
FROM vehicle_categories c
WHERE c.slug = 'sports'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'honda-civic-rs-1-5-turbo');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/65/2022_Honda_Civic_RS_1.5_FE1_%2820220317%29_01.jpg/1280px-2022_Honda_Civic_RS_1.5_FE1_%2820220317%29_01.jpg', 1
FROM vehicles v
WHERE v.slug = 'honda-civic-rs-1-5-turbo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/65/2022_Honda_Civic_RS_1.5_FE1_%2820220317%29_01.jpg/1280px-2022_Honda_Civic_RS_1.5_FE1_%2820220317%29_01.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9a/2022_Honda_Civic_RS_1.5_FE1_%2820220317%29_02.jpg/1280px-2022_Honda_Civic_RS_1.5_FE1_%2820220317%29_02.jpg', 0
FROM vehicles v
WHERE v.slug = 'honda-civic-rs-1-5-turbo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9a/2022_Honda_Civic_RS_1.5_FE1_%2820220317%29_02.jpg/1280px-2022_Honda_Civic_RS_1.5_FE1_%2820220317%29_02.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/55/Honda_Civic_1.5_RS_Turbo_2022.jpg/1280px-Honda_Civic_1.5_RS_Turbo_2022.jpg', 0
FROM vehicles v
WHERE v.slug = 'honda-civic-rs-1-5-turbo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/55/Honda_Civic_1.5_RS_Turbo_2022.jpg/1280px-Honda_Civic_1.5_RS_Turbo_2022.jpg');

-- ---- Toyota Agya GR Sport ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Toyota Agya GR Sport', 'toyota-agya-gr-sport', 'Toyota', 'Agya GR Sport CVT', 2022, 115000000, 11, 'City car ringkas untuk lalu-lalang perkotaan, paket GR Sport.', '1.2L NA', 'CVT', 'Bensin', 'Grey Metallic', 1, NOW() - INTERVAL 12 DAY
FROM vehicle_categories c
WHERE c.slug = 'city-car'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'toyota-agya-gr-sport');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d4/2022_Toyota_Agya_1.2_G_GR_Sport_B101RA_%2820220317%29_02.jpg/1280px-2022_Toyota_Agya_1.2_G_GR_Sport_B101RA_%2820220317%29_02.jpg', 1
FROM vehicles v
WHERE v.slug = 'toyota-agya-gr-sport'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d4/2022_Toyota_Agya_1.2_G_GR_Sport_B101RA_%2820220317%29_02.jpg/1280px-2022_Toyota_Agya_1.2_G_GR_Sport_B101RA_%2820220317%29_02.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/12/2022_Toyota_Agya_1.2_G_GR_Sport_B101RA_%2820220317%29_01.jpg/1280px-2022_Toyota_Agya_1.2_G_GR_Sport_B101RA_%2820220317%29_01.jpg', 0
FROM vehicles v
WHERE v.slug = 'toyota-agya-gr-sport'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/1/12/2022_Toyota_Agya_1.2_G_GR_Sport_B101RA_%2820220317%29_01.jpg/1280px-2022_Toyota_Agya_1.2_G_GR_Sport_B101RA_%2820220317%29_01.jpg');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/53/2021_Toyota_Agya_1.2_G_GR_Sport_B101RA_%2820220506%29.jpg/1280px-2021_Toyota_Agya_1.2_G_GR_Sport_B101RA_%2820220506%29.jpg', 0
FROM vehicles v
WHERE v.slug = 'toyota-agya-gr-sport'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://thumb.wikimedia.org/wikipedia/commons/thumb/5/53/2021_Toyota_Agya_1.2_G_GR_Sport_B101RA_%2820220506%29.jpg/1280px-2021_Toyota_Agya_1.2_G_GR_Sport_B101RA_%2820220506%29.jpg');
