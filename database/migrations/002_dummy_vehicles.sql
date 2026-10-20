-- 002_dummy_vehicles.sql — seed data kendaraan dummy (12 unit + kategori MPV/City Car).
-- Dijalankan SEKALI saat start pertama oleh initDb (marker di schema_migrations),
-- sehingga aman dijalankan berulang dan aman jika dihapus manual:
--   undo: DELETE FROM vehicles WHERE slug IN (... daftar slug di bawah);
--         HAPUS juga baris '002_dummy_vehicles' di schema_migrations bila ingin di-seed lagi.
-- Foto = URL ilustrasi umum (unsplash), bukan foto unit asli (project demo).

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
SELECT v.id, 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=1200&auto=format&fit=crop', 1
FROM vehicles v
WHERE v.slug = 'toyota-fortuner-2-4-vrz'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1571068316344-75bc76f77890?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'toyota-fortuner-2-4-vrz'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1571068316344-75bc76f77890?q=80&w=1200&auto=format&fit=crop');

-- ---- Toyota Corolla Cross 1.8 HEV ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Toyota Corolla Cross 1.8 HEV', 'toyota-corolla-cross-1-8-hev', 'Toyota', 'Corolla Cross 1.8 HEV', 2024, 500000000, 6, 'SUV hybrid efisien dengan konsumsi BBM rendah dan fitur lengkap di kelasnya.', '1.8L Hybrid', 'e-CVT', 'Hybrid', 'Blue Metallic', 1, NOW() - INTERVAL 2 DAY
FROM vehicle_categories c
WHERE c.slug = 'electric'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'toyota-corolla-cross-1-8-hev');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?q=80&w=1200&auto=format&fit=crop', 1
FROM vehicles v
WHERE v.slug = 'toyota-corolla-cross-1-8-hev'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'toyota-corolla-cross-1-8-hev'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'toyota-corolla-cross-1-8-hev'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?q=80&w=1200&auto=format&fit=crop');

-- ---- Toyota Avanza 1.5 G ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Toyota Avanza 1.5 G', 'toyota-avanza-1-5-g', 'Toyota', 'Avanza 1.5 G CVT', 2023, 245000000, 8, 'MPV keluarga terlaris di Indonesia. Tampil segar dan hemat bahan bakar.', '1.5L 2NR-VE', 'CVT', 'Bensin', 'Silver Metallic', 1, NOW() - INTERVAL 3 DAY
FROM vehicle_categories c
WHERE c.slug = 'mpv'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'toyota-avanza-1-5-g');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=1200&auto=format&fit=crop', 1
FROM vehicles v
WHERE v.slug = 'toyota-avanza-1-5-g'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1570733577524-3a047079e80d?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'toyota-avanza-1-5-g'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1570733577524-3a047079e80d?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'toyota-avanza-1-5-g'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=1200&auto=format&fit=crop');

-- ---- Honda BR-V Prestige ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Honda BR-V Prestige', 'honda-brv-prestige', 'Honda', 'BR-V Prestige CVT', 2023, 305000000, 9, 'SUV 7-penumpang desain modern, kabin lega untuk keluarga.', '1.5L DOHC i-VTEC', 'CVT', 'Bensin', 'Platinum White', 1, NOW() - INTERVAL 4 DAY
FROM vehicle_categories c
WHERE c.slug = 'suv'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'honda-brv-prestige');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=1200&auto=format&fit=crop', 1
FROM vehicles v
WHERE v.slug = 'honda-brv-prestige'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1571068316344-75bc76f77890?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'honda-brv-prestige'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1571068316344-75bc76f77890?q=80&w=1200&auto=format&fit=crop');

-- ---- Mitsubishi Xpander Ultimate ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Mitsubishi Xpander Ultimate', 'mitsubishi-xpander-ultimate', 'Mitsubishi', 'Xpander Ultimate', 2023, 290000000, 7, 'MPV desain Dynamic Shield dengan ruang kabin lega. Favorit keluarga muda.', '1.5L MIVEC', 'AT', 'Bensin', 'Metallic White', 1, NOW() - INTERVAL 5 DAY
FROM vehicle_categories c
WHERE c.slug = 'mpv'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'mitsubishi-xpander-ultimate');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=1200&auto=format&fit=crop', 1
FROM vehicles v
WHERE v.slug = 'mitsubishi-xpander-ultimate'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1570733577524-3a047079e80d?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'mitsubishi-xpander-ultimate'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1570733577524-3a047079e80d?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'mitsubishi-xpander-ultimate'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=1200&auto=format&fit=crop');

-- ---- Honda Brio Satya E ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Honda Brio Satya E', 'honda-brio-satya-e-cvt', 'Honda', 'Brio Satya E CVT', 2023, 160000000, 12, 'City car populer, ideal sebagai mobil pertama. Sangat irit bensin.', '1.2L 3EA5', 'CVT', 'Bensin', 'Rallye Red', 1, NOW() - INTERVAL 6 DAY
FROM vehicle_categories c
WHERE c.slug = 'city-car'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'honda-brio-satya-e-cvt');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1555215695-3004980ad54e?q=80&w=1200&auto=format&fit=crop', 1
FROM vehicles v
WHERE v.slug = 'honda-brio-satya-e-cvt'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1555215695-3004980ad54e?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'honda-brio-satya-e-cvt'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1553440569-bcc63803a83d?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'honda-brio-satya-e-cvt'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1553440569-bcc63803a83d?q=80&w=1200&auto=format&fit=crop');

-- ---- Toyota Kijang Innova 2.0 G ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Toyota Kijang Innova 2.0 G', 'toyota-kijang-innova-2-0-g', 'Toyota', 'Kijang Innova 2.0 G', 2023, 390000000, 6, 'Keseimbangan kenyamanan dan kepraktisan untuk keluarga.', '2.0L Dual VVT-i', 'CVT', 'Bensin', 'Attitude Black', 1, NOW() - INTERVAL 7 DAY
FROM vehicle_categories c
WHERE c.slug = 'mpv'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'toyota-kijang-innova-2-0-g');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=1200&auto=format&fit=crop', 1
FROM vehicles v
WHERE v.slug = 'toyota-kijang-innova-2-0-g'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1570733577524-3a047079e80d?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'toyota-kijang-innova-2-0-g'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1570733577524-3a047079e80d?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'toyota-kijang-innova-2-0-g'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=1200&auto=format&fit=crop');

-- ---- Toyota GR86 2.4 ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Toyota GR86 2.4', 'toyota-gr86-2-4', 'Toyota', 'GR86 2.4 Boxer', 2023, 660000000, 3, 'Sport coupe bermesin boxer yang seru dikendarai.', '2.4L FA24 Boxer', '6MT', 'Bensin', 'Ignition Red', 1, NOW() - INTERVAL 8 DAY
FROM vehicle_categories c
WHERE c.slug = 'sports'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'toyota-gr86-2-4');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=1200&auto=format&fit=crop', 1
FROM vehicles v
WHERE v.slug = 'toyota-gr86-2-4'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'toyota-gr86-2-4'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1502877338535-766e1452684a?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'toyota-gr86-2-4'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1502877338535-766e1452684a?q=80&w=1200&auto=format&fit=crop');

-- ---- Wuling Air EV Long Range ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Wuling Air EV Long Range', 'wuling-air-ev-long-range', 'Wuling', 'Air EV Long Range', 2023, 215000000, 9, 'Hatchback listrik kompak untuk mobilitas kota sehari-hari.', 'Motor Listrik 65 kW', 'Single-Speed', 'Listrik', 'Aurora Silver', 1, NOW() - INTERVAL 9 DAY
FROM vehicle_categories c
WHERE c.slug = 'electric'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'wuling-air-ev-long-range');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?q=80&w=1200&auto=format&fit=crop', 1
FROM vehicles v
WHERE v.slug = 'wuling-air-ev-long-range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'wuling-air-ev-long-range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'wuling-air-ev-long-range'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?q=80&w=1200&auto=format&fit=crop');

-- ---- Mitsubishi Pajero Sport Dakar ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Mitsubishi Pajero Sport Dakar', 'mitsubishi-pajero-sport-dakar', 'Mitsubishi', 'Pajero Sport Dakar 4x4', 2022, 480000000, 4, 'SUV 4x4 tahan banting untuk petualangan keluarga di segala medan.', '2.4L 4N15 8AT', '8AT', 'Diesel', 'Ferro Black', 1, NOW() - INTERVAL 10 DAY
FROM vehicle_categories c
WHERE c.slug = 'suv'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'mitsubishi-pajero-sport-dakar');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=1200&auto=format&fit=crop', 1
FROM vehicles v
WHERE v.slug = 'mitsubishi-pajero-sport-dakar'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1571068316344-75bc76f77890?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'mitsubishi-pajero-sport-dakar'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1571068316344-75bc76f77890?q=80&w=1200&auto=format&fit=crop');

-- ---- Honda Civic RS 1.5 Turbo ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Honda Civic RS 1.5 Turbo', 'honda-civic-rs-1-5-turbo', 'Honda', 'Civic RS 1.5 VTEC Turbo', 2022, 510000000, 4, 'Sedan sport bermesin turbo. Perpaduan performa dan kenyamanan.', '1.5L VTEC Turbo', 'CVT', 'Bensin', 'Sonic Grey Pearl', 1, NOW() - INTERVAL 11 DAY
FROM vehicle_categories c
WHERE c.slug = 'sports'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'honda-civic-rs-1-5-turbo');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=1200&auto=format&fit=crop', 1
FROM vehicles v
WHERE v.slug = 'honda-civic-rs-1-5-turbo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'honda-civic-rs-1-5-turbo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1502877338535-766e1452684a?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'honda-civic-rs-1-5-turbo'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1502877338535-766e1452684a?q=80&w=1200&auto=format&fit=crop');

-- ---- Toyota Agya GR Sport ----
INSERT INTO vehicles (category_id, name, slug, brand, model, year, price, stock, description, engine, transmission, fuel_type, color, is_available, created_at)
SELECT c.id, 'Toyota Agya GR Sport', 'toyota-agya-gr-sport', 'Toyota', 'Agya GR Sport CVT', 2022, 115000000, 11, 'City car ringkas untuk lalu-lalang perkotaan, paket GR Sport.', '1.2L NA', 'CVT', 'Bensin', 'Grey Metallic', 1, NOW() - INTERVAL 12 DAY
FROM vehicle_categories c
WHERE c.slug = 'city-car'
  AND NOT EXISTS (SELECT 1 FROM vehicles v WHERE v.slug = 'toyota-agya-gr-sport');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1555215695-3004980ad54e?q=80&w=1200&auto=format&fit=crop', 1
FROM vehicles v
WHERE v.slug = 'toyota-agya-gr-sport'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1555215695-3004980ad54e?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'toyota-agya-gr-sport'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?q=80&w=1200&auto=format&fit=crop');
INSERT INTO vehicle_images (vehicle_id, image_url, is_primary)
SELECT v.id, 'https://images.unsplash.com/photo-1553440569-bcc63803a83d?q=80&w=1200&auto=format&fit=crop', 0
FROM vehicles v
WHERE v.slug = 'toyota-agya-gr-sport'
  AND NOT EXISTS (SELECT 1 FROM vehicle_images vi WHERE vi.vehicle_id = v.id AND vi.image_url = 'https://images.unsplash.com/photo-1553440569-bcc63803a83d?q=80&w=1200&auto=format&fit=crop');
