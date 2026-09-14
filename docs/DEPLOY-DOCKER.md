# YAW — Deploy production (Docker-only)
#
# Prasyarat: Docker 29+ + Compose v2, file `.env.prod` (salin dari `.env.prod.example`).
#
#   cp .env.prod.example .env.prod   # lalu isi DB_PASSWORD, DB_ROOT_PASSWORD, JWT_SECRET, dsb.
#   ./scripts/deploy.sh up           # atau: make deploy-up
#   ./scripts/deploy.sh verify
#
# Arsitektur: yaw-web (nginx:80, serve Flutter web + proxy /api/ & /uploads/)
# → yaw-backend (node:3002, UPLOAD_PATH=/app/uploads) → yaw-db (mariadb internal).
# DB TIDAK mem-publish port ke host. HTTPS di-terminasi di host (certbot --nginx)
# atau reverse-proxy di depan container yaw-web (lihat "Nginx / HTTPS" di bawah).

## 1. Prasyarat

- Server Linux dengan Docker 29.8.0+ dan Compose 5.5.1+:
  `docker --version && docker compose version`
- Port 80 (dan 443 bila pakai TLS) terbuka ke server.
- DNS `<domain>` sudah mengarah (A record) ke IP server bila
  `API_BASE_URL=https://<domain>/api/v1`.

## 2. Konfigurasi `.env.prod`

```bash
cp .env.prod.example .env.prod
nano .env.prod
```

| Key | Isi |
| --- | --- |
| `DB_NAME` / `DB_USER` | default `yaw` / `yaw_user` (boleh dipertahankan) |
| `DB_PASSWORD`, `DB_ROOT_PASSWORD` | WAJIB diganti (`CHANGE_ME` tidak boleh lolos) |
| `JWT_SECRET` | WAJIB, minimal 32 karakter acak — `openssl rand -base64 48` |
| `CORS_ORIGIN` | origin web, mis. `https://example.com` (tanpa trailing slash) |
| `API_BASE_URL` | URL API publik yang **dibake** ke Flutter web saat build, mis. `https://example.com/api/v1` |
| `BASE_HREF` | default `/` — ubah hanya bila serve web dari sub-path |

> `API_BASE_URL` dibaca `String.fromEnvironment` saat `flutter build web`,
> jadi ganti nilainya = rebuild image web (`./scripts/deploy.sh web-rebuild`).

## 3. Build & up

```bash
./scripts/deploy.sh up        # build + up -d + ps
./scripts/deploy.sh verify    # cek /api/health via container
```

atau via make:

```bash
make deploy-build   # validasi API_BASE_URL + compose build
make deploy-up      # up -d + ps
make deploy-verify  # curl localhost/api/health + petunjuk login
```

Cek manual:

```bash
curl -s http://localhost/api/health
curl -s -X POST http://localhost/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@yaw.id","password":"admin123"}'
```

## 4. Nginx / HTTPS

Container `yaw-web` hanya listen port 80. TLS di-terminasi di host:

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d <domain>
```

Certbot di host me-reverse-proxy ke `http://localhost:80`
(web sudah mem-proxy `/api/` dan `/uploads/` ke `yaw-backend:3002`
dengan header `X-Forwarded-*`, jadi tidak perlu config proxy tambahan
untuk API). Alternatif: pasang reverse-proxy (nginx/traefik) apa pun
di depan `yaw-web:80` dan teruskan header `Host` + `X-Forwarded-Proto`.

## 5. Seed admin

Saat DB volume masih kosong, backend otomatis migrasi + seed saat start:

- admin: `admin@yaw.id` / `admin123` (role admin)
- user: `user@yaw.id` / `user123` (role user)

Segera ganti password setelah login pertama.
Seed ulang manual (di dalam container backend):

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod exec yaw-backend npm run seed
```

> Catatan: image production hanya berisi `dist/` + `node_modules` prod,
> jadi `npm run seed` (tsx) tidak tersedia di image — bila perlu seed ulang,
> jalankan dari checkout repo terhadap DB yang sama, atau rebuild image
> dengan skrip seed. Untuk deploy awal, seed otomatis saat start sudah cukup.

## 6. Update

```bash
git pull
./scripts/deploy.sh up        # rebuild image yang berubah + restart
```

Hanya web yang berubah (mis. ganti `API_BASE_URL`):

```bash
./scripts/deploy.sh web-rebuild
```

## 7. Backup volume

```bash
docker run --rm -v yaw_data:/data -v "$PWD":/backup alpine \
  tar czf /backup/yaw_data-$(date +%F).tar.gz -C /data .
docker run --rm -v yaw-uploads:/data -v "$PWD":/backup alpine \
  tar czf /backup/yaw_uploads-$(date +%F).tar.gz -C /data .
```

Restore: `tar xzf <file> -C` ke volume kosong yang di-mount ke `/data`.

## 8. Troubleshooting

| Gejala | Penyebab umum | Perintah / solusi |
| --- | --- | --- |
| `API_BASE_URL kosong` saat build | `.env.prod` belum diisi | `cp .env.prod.example .env.prod`, isi `API_BASE_URL=https://<domain>/api/v1` |
| `JWT_SECRET` / `DB_PASSWORD` error interpolasi | secret masih kosong | isi di `.env.prod` (min 32 char acak untuk JWT) |
| `pool unreachable` / DB 503 | `yaw-db` belum healthy | `docker compose -f docker-compose.prod.yml --env-file .env.prod ps`, `logs yaw-db`; backend otomatis retry saat start |
| CORS error di browser | `CORS_ORIGIN` ≠ origin web | samakan `CORS_ORIGIN=https://<domain>`, lalu `up` ulang backend |
| Gambar `/uploads/...` 404 | volume `yaw-uploads` kosong setelah pindah host | restore backup uploads; cek `logs yaw-backend` (multer menulis ke `/app/uploads`) |
| Route web refresh 404 | fallback SPA hilang | pastikan `docker/nginx-web.conf` memuat `try_files ... /index.html` |
| Port 80 bentrok | nginx host / service lain | hentikan pemakai lama atau mapping ulang `ports` di `docker-compose.prod.yml` |
| Agak berat saat build web | Flutter build memang besar | wajar (image cirruslabs + `flutter build web --release`); jangan build di VPS 1GB tanpa swap |
| `compileSdk` / AGP error | SUDAH DIPERBAIKI — bukan isu deploy Docker | abaikan untuk deploy web+backend ini (hanya relevan untuk build APK lama) |

## 9. Build APK/IPA release (mobile)

Build mobile terpisah dari Docker web — jalankan di workstation (bukan server):

| Target | Perintah | Output |
| --- | --- | --- |
| **APK rilis** | `flutter build apk --release --dart-define=API_BASE_URL=https://<domain>/api/v1` | `build/app/outputs/flutter-apk/app-release.apk` |
| **App Bundle (Play Store)** | `flutter build appbundle --release --dart-define=API_BASE_URL=https://<domain>/api/v1` | `build/app/outputs/bundle/release/app-release.aab` |
| **Android emulator (dev)** | `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3002/api/v1` | — (hot reload, localhost via 10.0.2.2) |
| **iOS IPA rilis** | `flutter build ipa --release --dart-define=API_BASE_URL=https://<domain>/api/v1` | `build/ios/ipa/app.ipa` (butuh Apple Developer, codesign, provisioning) |

> **HTTPS wajib untuk production mobile** — Android cleartext traffic + iOS ATS memblokir `http://` tanpa exception. Repo **tidak** menambahkan `android:usesCleartextTraffic` atau `NSAppTransportSecurity` exception. Gunakan `https://<domain>/api/v1` (domain dengan TLS valid) untuk build rilis. Emulator dev boleh `http://10.0.2.2:3002/api/v1`.

> **compileSdk 37 / AGP 9.1.1**: Sudah dikonfigurasi di repo (`android/build.gradle.kts`, `android/app/build.gradle.kts`). Tidak perlu tindakan tambahan.
