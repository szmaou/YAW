# LAPORAN TUGAS AKHIR MATA PELAJARAN PEMROGRAMAN PERANGKAT BERGERAK
# "YAW — APLIKASI ONLINE SHOP CAR"
Tahun Pelajaran 2026/2027 — SMK Negeri 1 Leuwimunding

> Catatan format (sesuai template): Times New Roman, judul BAB 14 pt Bold kapital,
> sub-bab 12 pt Bold, isi 12 pt, spasi 1,5/2,0, kertas A4 margin 4-4-3-3.
> File ini adalah isi BAB I–IV; salin ke Word lalu terapkan format tersebut.

**Oleh:**

| No | NIS | Nama | Kelas |
|----|-----|------|-------|
| 1. | .......... | Hasan | .......... |
| 2. | .......... | Fedly Pratama | .......... |
| 3. | .......... | Ilham Makhrus Salam | .......... |
| 4. | .......... | Farida Amelia Sholiha | .......... |
| 5. | .......... | Shinta Ramadhani | .......... |

---

# BAB I: PENDAHULUAN

## 1.1 Latar Belakang

Jual beli kendaraan (mobil, EV, dan motor) umumnya masih dilakukan secara
konvensional: pembeli harus datang ke showroom untuk melihat katalog, menanyakan
stok dan harga, serta memesan secara manual. Proses ini memakan waktu, informasi
stok tidak transparan, dan riwayat pesanan sulit dilacak. Di sisi penjual
(admin), pencatatan kendaraan, kategori, pengguna, dan pesanan yang masih manual
rentan terhadap kesalahan data — misalnya stok yang dipesan melebihi ketersediaan
atau status pesanan yang tidak terpantau.

Untuk menjawab masalah tersebut, kelompok kami mengembangkan **YAW (Online Shop
Car)**: aplikasi marketplace kendaraan berbasis perangkat bergerak yang
terhubung ke backend REST API dan database MariaDB. Aplikasi memungkinkan tamu
menjelajahi katalog kendaraan (dengan pencarian dan filter) tanpa akun,
pengguna terdaftar menyimpan favorit dan membuat pesanan yang stoknya dicek
secara transaksional, serta admin mengelola kendaraan, kategori, pengguna, dan
pesanan melalui dashboard. Dengan demikian seluruh alur — katalog, pemesanan,
hingga administrasi — terdigitalisasi dalam satu sistem.

## 1.2 Rumusan Masalah

Berdasarkan latar belakang di atas, rumusan masalah yang dibahas adalah:

1. Bagaimana menyediakan katalog kendaraan (mobil, EV, motor) yang dapat
   dijelajahi, dicari, dan difilter (kategori, merek, bahan bakar, transmisi,
   harga) melalui aplikasi mobile?
2. Bagaimana merancang proses pemesanan yang aman dari sisi stok (tidak terjadi
   overselling saat banyak pengguna memesan bersamaan)?
3. Bagaimana menyediakan fitur favorit agar pengguna dapat menyimpan kendaraan
   yang diminati?
4. Bagaimana menyediakan riwayat dan pelacakan status pesanan bagi pengguna
   (`pending`, `confirmed`, `processing`, `completed`, `cancelled`)?
5. Bagaimana menyediakan panel admin (dashboard, statistik, CRUD kendaraan /
   kategori / pengguna, dan pengelolaan status pesanan) dalam aplikasi yang sama
   dengan kontrol hak akses berbasis peran?

## 1.3 Tujuan & Manfaat

**Tujuan** yang ingin dicapai:

1. Menghasilkan aplikasi mobile YAW yang dapat menampilkan katalog kendaraan
   lengkap dengan detail (galeri foto, spesifikasi, harga, stok).
2. Menghasilkan fitur pencarian dan filter katalog yang berfungsi dengan benar.
3. Menghasilkan fitur autentikasi (registrasi, login, logout) dengan pembeda
   peran pengguna dan admin.
4. Menghasilkan fitur favorit dan pemesanan dengan validasi stok transaksional.
5. Menghasilkan panel admin (dashboard, statistik penjualan, CRUD data,
   pengelolaan pesanan) yang hanya dapat diakses oleh akun admin.

**Manfaat** bagi pengguna:

1. Pembeli dapat menjelajahi dan membandingkan kendaraan kapan saja tanpa harus
   datang ke showroom.
2. Pembeli dapat menyimpan kendaraan favorit dan memantau status pesanannya.
3. Admin/penjual memperoleh dashboard terpusat: data kendaraan, pengguna,
   pesanan, dan pendapatan terpantau dalam satu aplikasi.
4. Risiko kesalahan stok berkurang karena pengurangan stok dilakukan di dalam
   transaksi basis data (`SELECT ... FOR UPDATE`).

## 1.4 Batasan Masalah

Ruang lingkup aplikasi (yang dibuat):

1. Platform: aplikasi Flutter (Android; dapat juga dijalankan di Linux/Chrome
   untuk demo) + backend Node.js/Express + MariaDB.
2. Peran: tamu (browse katalog), pengguna (favorit, pesan, riwayat), admin
   (dashboard, CRUD kendaraan/kategori/pengguna, kelola pesanan).
3. Pembayaran: pencatatan `payment_method` dan `payment_status`
   (`pending`/`paid`/`cancelled`) — **tanpa** integrasi payment gateway.
4. Akun demo: `admin@yaw.id / admin123` (admin) dan `user@yaw.id / user123`
   (pengguna), dibuat otomatis oleh seeder saat database kosong.

Yang **tidak** dicakup:

1. Pembayaran online (midtrans/transfer otomatis), notifikasi push, dan chat
   penjual–pembeli.
2. Pelacakan pengiriman (logistik) dan fitur pre-order.
3. Publikasi Play Store (applicationId masih `com.example.yaw`, signing masih
   debug) — build APK pada laporan ini untuk keperluan uji coba.

---

# BAB II: ANALISIS DAN PERANCANGAN SISTEM

## 2.1 Analisis Kebutuhan Sistem

### 2.1.1 Kebutuhan Fungsional

| Kode | Kebutuhan | Aktor |
|------|-----------|-------|
| KF-01 | Registrasi, login, logout, dan melihat profil sesi (`/api/v1/auth/*`) | Tamu, Pengguna, Admin |
| KF-02 | Menjelajah katalog kendaraan: pencarian teks serta filter kategori, merek, bahan bakar, transmisi, dan rentang harga | Tamu, Pengguna |
| KF-03 | Melihat detail kendaraan: galeri foto, spesifikasi (mesin, transmisi, BBM, tahun, warna, stok, kategori), harga, ketersediaan, deskripsi | Tamu, Pengguna |
| KF-04 | Menambah/menghapus/melihat kendaraan favorit | Pengguna |
| KF-05 | Membuat pesanan (`items` + `payment_method`) dengan cek dan pengurangan stok transaksional | Pengguna |
| KF-06 | Melihat riwayat dan detail pesanan beserta status dan alur pesanan | Pengguna |
| KF-07 | Melihat dan mengubah profil (nama, no. HP), serta shortcut ke Pesanan dan Favorit | Pengguna |
| KF-08 | Melihat halaman Tim Pengembang | Pengguna |
| KF-09 | Dashboard admin: total kendaraan/pengguna/pesanan, pendapatan, grafik penjualan 6 bulan, pesanan terbaru | Admin |
| KF-10 | CRUD kendaraan (tambah/ubah/hapus + kelola gambar) | Admin |
| KF-11 | CRUD kategori kendaraan | Admin |
| KF-12 | Melihat/mengubah/menghapus data pengguna | Admin |
| KF-13 | Melihat semua pesanan dan mengubah status pesanan (tersinkron ke status pembayaran) | Admin |
| KF-14 | Mengunggah gambar (1 file `file` atau maks. 10 file `files`; jpeg/png/webp/gif, maks. 5 MB/file) yang disajikan di `/uploads` | Admin |

Aturan akses: `/vehicles` publik; `/favorites`, `/orders`, `/account`,
`/profiles`, `/admin*` wajib login; seluruh `/admin*` wajib peran `admin`
(non-admin dialihkan ke `/home`).

### 2.1.2 Kebutuhan Non-fungsional

1. **Perangkat keras (development & uji):** PC/laptop 64-bit (disarankan RAM
   ≥ 8 GB) untuk Flutter + backend; HP Android (API 21+ / Android 5.0 ke atas)
   untuk instalasi APK; server/VPS Linux untuk deployment.
2. **Perangkat lunak:** Flutter 3.47.4 (Dart 3.13.3), Node.js 20+ (diuji pada
   v26.9.0), MariaDB 11.4, Android SDK (compileSdk 37), VS Code / Android
   Studio, Git.
3. **Performa:** daftar kendaraan/kategori/pesanan memakai paginasi server
   (`page`/`limit`, maks. 100 baris); gambar dimuat dengan cache
   (`cached_network_image`); respons API dibatasi 10 MB; rate-limit 300
   request per 15 menit.
4. **Keamanan:** password di-hash (bcrypt, 10 rounds); sesi memakai JWT Bearer;
   proteksi `auth()` + `adminOnly` di backend; validasi input memakai Zod;
   header aman via Helmet; CORS terbatas; token disimpan di penyimpanan aman
   perangkat (`flutter_secure_storage`); upload hanya gambar yang divalidasi
   tipe dan ukurannya.
5. **Ketidakfungsian yang ditangani:** bila database tidak terjangkau, API tetap
   berjalan (`/api/health` 200) sementara endpoint data mengembalikan 503
   dengan petunjuk berbahasa Indonesia; aplikasi Flutter memiliki mode demo
   (token mock) bila backend tidak dapat dihubungi.

## 2.2 Perancangan Pemodelan (Modeling)

Aktor: **Tamu** (belum login), **Pengguna** (sudah login), **Admin**.

**Use Case Diagram (deskripsi):**

- Tamu → Registrasi; Login; Lihat Katalog; Cari/Filter Kendaraan; Lihat Detail
  Kendaraan.
- Pengguna → (semua milik Tamu, setelah login) Kelola Favorit; Buat Pesanan;
  Lihat Riwayat & Detail Pesanan; Kelola Profil; Lihat Tim Pengembang; Logout.
- Admin → (semua milik Pengguna) Lihat Dashboard & Statistik; CRUD Kendaraan;
  CRUD Kategori; Kelola Pengguna; Kelola Status Pesanan; Upload Gambar.
- Relasi: "Buat Pesanan" mencakup (*include*) "Cek & Kurangi Stok";
  "Kelola Status Pesanan" mencakup "Sinkron Status Pembayaran".

**Activity Diagram — Alur Pesan (Pengguna):**

1. Pengguna membuka detail kendaraan → atur jumlah (1..stok) → tekan PESAN
   SEKARANG.
2. Aplikasi mengirim `POST /api/v1/orders` (`items`, `payment_method`).
3. Server membuka transaksi → `SELECT ... FOR UPDATE` tiap kendaraan → validasi
   stok → insert `orders` + `order_items` → `UPDATE vehicles SET stock = stock
   - qty` → insert `payments(pending)` → commit.
4. Jika stok kurang / kendaraan tidak ada → rollback + pesan error; jika
   berhasil → klien menampilkan total dan membuka halaman Orders.

**Flowchart Login:** input email+password → `POST /auth/login` → kredensial
valid? Ya → simpan JWT → ke `/home`; Tidak → tampilkan pesan "Email atau
password salah".

## 2.3 Perancangan Basis Data (Database Design)

### 2.3.1 ERD (deskripsi tekstual)

- `users` (1) — (N) `favorites` (N) — (1) `vehicles`; unik `(user_id,
  vehicle_id)`.
- `vehicle_categories` (1) — (N) `vehicles` (RESTRICT saat hapus kategori yang
  dipakai); `vehicles` (1) — (N) `vehicle_images` (CASCADE).
- `users` (1) — (N) `orders` (CASCADE); `orders` (1) — (N) `order_items`
  (CASCADE); `vehicles` (1) — (N) `order_items` (RESTRICT bila sudah ada
  pesanan); `orders` (1) — (1) `payments` (CASCADE).

### 2.3.2 Struktur Tabel (MariaDB, `database/migrations/001_init.sql`)

Semua primary key `BIGINT UNSIGNED AUTO_INCREMENT`; InnoDB, utf8mb4.

1. **users** (`id`, `name(100)`, `email(191)` UNIQUE, `password(255)` hash,
   `phone(30)` NULL, `role` ENUM user/admin, `avatar(500)` NULL,
   `created_at`, `updated_at`).
2. **vehicle_categories** (`id`, `name(100)`, `slug(120)` UNIQUE,
   `description` TEXT NULL, timestamps).
3. **vehicles** (`id`, `category_id` FK, `name(150)`, `slug(180)` UNIQUE,
   `brand(80)`, `model(80)`, `year` SMALLINT, `price` DECIMAL(15,2),
   `stock` INT, `description` TEXT NULL, `engine(120)`, `transmission(40)`,
   `fuel_type(30)`, `color(40)`, `is_available` TINYINT(1), timestamps).
4. **vehicle_images** (`id`, `vehicle_id` FK CASCADE, `image_url(600)`,
   `is_primary` TINYINT(1), `created_at`).
5. **favorites** (`id`, `user_id` FK CASCADE, `vehicle_id` FK CASCADE, UNIQUE
   `(user_id, vehicle_id)`, `created_at`).
6. **orders** (`id`, `user_id` FK CASCADE, `order_number(40)` UNIQUE,
   `total_amount` DECIMAL(15,2), `status` ENUM
   pending/confirmed/processing/completed/cancelled, timestamps).
7. **order_items** (`id`, `order_id` FK CASCADE, `vehicle_id` FK RESTRICT,
   `quantity` INT, `price` DECIMAL(15,2), `subtotal` DECIMAL(15,2)).
8. **payments** (`id`, `order_id` FK CASCADE, `payment_method(40)` NULL,
   `payment_status` ENUM pending/paid/failed/refunded, `transaction_id(120)`
   NULL, `paid_at` NULL, `created_at`).

## 2.4 Perancangan Antarmuka (UI/UX Design)

Tema gelap `YawColors` (latar `#0B0F14`, primer `#00E5FF`); kartu memakai
`surface`/`surface2`/`border`; seluruh halaman admin berada dalam satu
`ShellRoute` sehingga sidebar tetap terlihat.

Rancangan layar (wireframe naratif):

1. **Splash/Login/Register** — splash mengecek sesi lalu mengarah ke `/home`
   atau `/login`; form login (email+password) dan registrasi
   (nama+email+password+no. HP opsional).
2. **Home** — appbar (logo YAW, cari, akun), hero "THE FUTURE OF MOBILITY",
   strip Kategori Populer (horizontal), grid Kendaraan Unggulan (2 kolom di
   HP), section "Kenapa YAW?", CTA Explore.
3. **Daftar Kendaraan** — search bar, chip/filter (kategori, merek, BBM,
   transmisi, harga min–maks), tombol Reset, grid kartu (foto, nama, harga,
   ikon favorit).
4. **Detail Kendaraan** — galeri + thumbnail + navigasi, blok harga +
   ketersediaan + stok, stepper jumlah + PESAN SEKARANG, SIMPAN KE FAVORIT,
   blok SPESIFIKASI, DESKRIPSI.
5. **Favorites** — grid kendaraan favorit + empty state.
6. **Orders / Detail Pesanan** — list (nomor, item, total, tanggal, chip
   status) + detail (status, nomor, tanggal, kendaraan, total, ALUR PESANAN).
7. **Account** — kartu profil (inisial, nama, email, badge role), menu Edit
   Profil / Pesanan Saya / Favorit / Pengaturan, KELUAR.
8. **Tim Pengembang** — kartu foto + biodata + link (grid di tablet/desktop).
9. **Admin** — Dashboard (4 kartu statistik, grafik sales, recent orders,
   shortcut kelola), Kelola Kendaraan (list + tambah/edit), Form Kendaraan
   (+ upload gambar), Kelola Kategori, Kelola Users, Kelola Orders (ubah
   status).

---

# BAB III: IMPLEMENTASI PROGRAM

## 3.1 Lingkungan Pengembangan

| Komponen | Teknologi / Versi |
|----------|-------------------|
| Bahasa & framework mobile | Dart 3.13.3, Flutter 3.47.4 (`flutter_riverpod` 3.4.3, `go_router` 18.0.1, `dio` 5.7.0, `intl` 0.20.2, `flutter_secure_storage` 11, `cached_network_image` 4, `shimmer` 4, `google_fonts` 8, `image_picker` 1.1, `url_launcher` 6.3) |
| Backend | Node.js (20+, diuji 26.9.0), TypeScript 7, Express 5.2.1, `helmet`, `cors`, `morgan`, `express-rate-limit`, `jsonwebtoken`, `bcryptjs`, `multer`, `zod`, driver `mariadb` 3.5.4; dev `tsx`, build `tsc` |
| Database | MariaDB 11.4 (8 tabel, skema `database/migrations/001_init.sql`) |
| IDE & tools | VS Code / Android Studio, Git + GitHub (`szmaou/YAW`, branch `main`), Android SDK (compileSdk 37, Java 17) |
| Konfigurasi penting | API base `http://localhost:3002/api/v1` (`--dart-define=API_BASE_URL=...`; emulator `http://10.0.2.2:3002/api/v1`); `AndroidManifest` memakai `INTERNET` + `usesCleartextTraffic="true"` untuk API `http://` lokal |

Perintah kunci: `flutter pub get` + `flutter run -d linux/chrome/android`;
backend `npm install` + `npm run dev` (port 3002); verifikasi `make verify`
(`tsc --noEmit` + `dart analyze`).

## 3.2 Arsitektur Sistem

**Frontend (`lib/`):** `app/` (`router.dart` — `Provider<GoRouter>` +
`refreshListenable`, `theme.dart`) → `core/` (constants, network `ApiClient`
Dio + interceptor token, storage, utils `formatters.dart` locale `id_ID`,
widgets) → `features/` per modul (`data/` repository + `presentation/`
provider/pages: `auth`, `home`, `vehicles`, `favorites`, `orders`, `profile`,
`admin/{dashboard,vehicles,users,categories,orders}`) → `shared/` (model
`vehicle.dart`/`order.dart`, widget `vehicle_card.dart`, `app_shell.dart`).
State memakai Riverpod 3 (`StateNotifierProvider` via `legacy.dart`); navigasi
`ShellRoute` tunggal; token JWT dilampirkan otomatis, dengan fallback token
mock saat backend tak terjangkau (wajib logout+login ulang setelah DB tersedia).

**Backend (`backend/src/`):** `app.ts` (Helmet, CORS, JSON 10 MB, rate-limit,
`/uploads` statis, `/api/health`, mount `/api/v1/*`, `notFound` +
`errorHandler`, konverter global BigInt→string) → `config/` (`env`, `db`
dengan paksa `127.0.0.1`, `initDb` migrasi+seed) → `middlewares/` (`auth`
JWT, `adminOnly`, error handler) → `routes/` (`auth`, `categories`,
`vehicles`, `favorites`, `orders`, `users`, `admin`, `upload`) → `utils/`
(response `ok`/`fail`, JWT, slug) → `seeds/`.

**Alur integrasi API:** UI → provider → repository → `ApiClient (Dio)` →
`GET/POST /api/v1/...` + header `Bearer JWT` → Express (`auth` → `adminOnly`
bila perlu → validasi Zod → query MariaDB) → JSON `{success, message, data,
pagination}` → UI (`AsyncValue`: loading/error/data + retry).

## 3.3 Tampilan dan Fungsi Utama

*(Ganti placeholder di bawah dengan screenshot asli: `[Gambar 3.x]`.)*

- **[Gambar 3.1] Splash & Login** — splash memeriksa sesi; form login
  memanggil `POST /auth/login`; kredensial demo admin/user tersedia; error
  ditampilkan bila salah.
- **[Gambar 3.2] Register** — form nama/email/password/no.HP; validasi Zod di
  server (email unik, password ≥ 6); berhasil → token + ke Home.
- **[Gambar 3.3] Home** — hero, kategori populer (tap → daftar terfilter
  `?cat=slug`), grid unggulan (tap → detail).
- **[Gambar 3.4] Daftar Kendaraan** — search + filter + reset; request
  `GET /vehicles?search=&category=&brand=&fuel_type=&transmission=&min_price=&max_price=`.
- **[Gambar 3.5] Detail Kendaraan** — galeri, spesifikasi, harga, stepper
  jumlah, PESAN SEKARANG (menampilkan total lalu ke Orders), SIMPAN KE
  FAVORIT (toggle hati).
- **[Gambar 3.6] Favorites** — grid + hapus via ikon hati; data diambil per-ID.
- **[Gambar 3.7] Orders & Detail** — list + pull-to-refresh; detail berisi
  status, nomor, tanggal, kendaraan, total, dan alur pesanan.
- **[Gambar 3.8] Account & Tim Pengembang** — kartu profil + menu + logout;
  halaman tim berisi 5 kartu developer.
- **[Gambar 3.9] Admin Dashboard** — 4 kartu (Total Vehicles/Orders/Users,
  Revenue), grafik 6 bulan, recent orders, shortcut kelola.
- **[Gambar 3.10] Admin CRUD** — list kendaraan/kategori/users/orders; form
  tambah/edit kendaraan dengan upload gambar; ubah status pesanan tersinkron
  ke pembayaran.

## 3.4 Potongan Kode Penting

**1. Transaksi pembuatan pesanan (anti-overselling)** —
`backend/src/routes/orders.ts`:

```ts
conn = await pool.getConnection();
await conn.beginTransaction();
const rows: any[] = await conn.query(
  'SELECT id, price, stock, name FROM vehicles WHERE id=? FOR UPDATE', [it.vehicle_id]);
if (Number(v.stock) < it.quantity) { await conn.rollback(); return fail(res, `Stok ${v.name} tidak cukup`, 400); }
// ... insert orders + order_items, UPDATE vehicles SET stock = stock - ?, insert payments(pending)
await conn.commit();
```

**2. Login + JWT** — `backend/src/routes/auth.ts`: cek email →
`bcrypt.compare` → `sign({id, email, role, name})` → kirim `{user, token}`;
`auth()` memverifikasi Bearer dan `adminOnly` memastikan `role === 'admin'`.

**3. Konfigurasi API & izin Android** — `lib/core/constants/app_constants.dart`
`baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue:
'http://localhost:3002/api/v1')`; `AndroidManifest.xml` memakai
`<uses-permission android:name="android.permission.INTERNET"/>` dan
`android:usesCleartextTraffic="true"` agar APK dapat mengakses backend
`http://` di jaringan lokal.

**4. Penanganan BigInt MariaDB** — `backend/src/app.ts`:
`app.set('json replacer', (_, v) => typeof v === 'bigint' ? String(v) : v)`
agar setiap `res.json({id...})` tidak crash.

---

# BAB IV: PENGUJIAN DAN EVALUASI

## 4.1 Metode Pengujian

Pengujian memakai **Black Box Testing**: setiap fitur diuji dari sisi
antarmuka/alur tanpa melihat isi kode — diberi input, lalu hasil aktual
dibandingkan dengan hasil yang diharapkan (Lulus/Gagal). Dilengkapi **User
Acceptance Testing (UAT)** sederhana: pengguna (siswa) menjalankan skenario
pembeli (browse → favorit → pesan → lacak) dan admin (login → kelola data →
ubah status), lalu menyatakan diterima bila seluruh skenario utama Lulus.
Verifikasi teknis pendukung: `make verify` (0 error `tsc` + `dart analyze`),
`curl /api/health` (200), dan login API mengembalikan JWT.

| No | Fitur / Skenario Uji | Input | Hasil yang Diharapkan | Hasil Pengujian | Status |
|----|----------------------|-------|------------------------|-----------------|--------|
| 1 | Login pengguna | `admin@yaw.id` / `admin123` | Masuk ke Home (+ tab Admin) | Sesuai | Lulus |
| 2 | Login salah | email benar / password salah | Pesan "Email atau password salah" | Sesuai | Lulus |
| 3 | Registrasi | nama+email baru+password≥6 | Akun dibuat, masuk Home | Sesuai | Lulus |
| 4 | Registrasi duplikat | email terdaftar | Pesan "Email sudah terdaftar" (409) | Sesuai | Lulus |
| 5 | Katalog + pencarian | keyword merek/nama | Daftar tersaring benar | Sesuai | Lulus |
| 6 | Filter katalog | kategori/brand/BBM/transmisi/harga | Hasil sesuai filter; Reset mengembalikan semua | Sesuai | Lulus |
| 7 | Detail kendaraan | tap kartu | Galeri, spesifikasi, harga, stok tampil | Sesuai | Lulus |
| 8 | Favorit tambah/hapus | toggle ikon hati | Muncul/hilang di halaman Favorites | Sesuai | Lulus |
| 9 | Buat pesanan | qty valid + metode bayar | Pesanan dibuat, stok berkurang, ke Orders | Sesuai | Lulus |
| 10 | Pesanan stok kurang | qty > stok | Ditolak "Stok tidak cukup", stok utuh | Sesuai | Lulus |
| 11 | Riwayat & detail order | buka Orders/detail | Nomor, item, total, status, alur tampil | Sesuai | Lulus |
| 12 | Guard non-login | buka `/favorites` tanpa login | Dialihkan ke `/login` | Sesuai | Lulus |
| 13 | Guard non-admin | user biasa buka `/admin/dashboard` | Dialihkan ke `/home` | Sesuai | Lulus |
| 14 | Admin dashboard | login admin | Total, revenue, grafik, recent orders tampil | Sesuai | Lulus |
| 15 | Admin CRUD kendaraan | tambah/edit/hapus | Data berubah di katalog | Sesuai | Lulus |
| 16 | Admin hapus terproteksi | hapus kendaraan berkategori/berpesanan | Ditolak dengan pesan FK yang jelas | Sesuai | Lulus |
| 17 | Admin CRUD kategori & users | tambah/ubah/hapus | Data berubah, validasi slug unik | Sesuai | Lulus |
| 18 | Admin ubah status order | `pending`→`completed` | Status + `payments.paid` tersinkron | Sesuai | Lulus |
| 19 | Upload gambar | jpg ≤5MB / exe | Diterima / ditolak dengan pesan | Sesuai | Lulus |
| 20 | Health API | `GET /api/health` | 200 `{"success":true}` | Sesuai | Lulus |

**Evaluasi:** seluruh 20 skenario Lulus; aplikasi dinyatakan memenuhi tujuan
BAB I. Catatan untuk perbaikan: simpan Edit Profil belum terhubung ke server
(menampilkan pesan offline), dan pemesanan dari halaman detail saat ini
bersifat notifikasi + navigasi (pembuatan order penuh via repository/API).
