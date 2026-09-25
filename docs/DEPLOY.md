# YAW — Deploy Docker (Compose: db + backend + web)

Panduan ringkas Bahasa Indonesia untuk VPS Linux (Ubuntu).
Satu `docker compose up` menjalankan MariaDB 11.4, backend Node, dan nginx
yang menyajikan Flutter web + proxy `/api/` dan `/uploads/` ke backend.
Host hanya butuh **docker** (+ **flutter** untuk build web) — tanpa
systemd unit, nginx host, maupun MariaDB native.

## 1. Prasyarat

```bash
docker --version          # butuh Docker 24+ (compose v2)
docker compose version
flutter --version         # untuk `make deploy-web`
```

## 2. Env deploy

```bash
cp .env.docker.example .env   # lalu isi nilai CHANGE_ME
```

Isi penting: `DB_PASSWORD` + `DB_ROOT_PASSWORD` (acak, `openssl rand -base64 24`),
`JWT_SECRET` 32+ karakter acak (`openssl rand -base64 48`),
`CORS_ORIGIN=https://<domain>` dan `API_BASE_URL=https://<domain>/api/v1`
(wajib sama persis dengan URL yang dibuka user — di-bake ke web saat build).

Catatan: `DB_HOST` harus tetap `db` (nama service compose); container backend
selalu listen di port internal `3002` (`APP_PORT` hanya mengatur port host).

## 3. Build web + up

```bash
make deploy-web   # flutter build web --release (API_BASE_URL dari .env) -> build/web
make deploy-up    # docker compose up -d --build (cek .env + build/web dulu)
docker compose ps
```

Boot pertama: service `db` dibuat dari image `mariadb:11.4` (database + user
dibuat otomatis dari `DB_*`), lalu backend menjalankan migrasi + seed otomatis
(`initDb`): login awal `admin@yaw.id / admin123` (ganti setelah masuk).

## 4. Verifikasi

```bash
make deploy-verify
curl -s -X POST http://localhost/api/v1/auth/login -H 'Content-Type: application/json' -d '{"email":"admin@yaw.id","password":"admin123"}'
```

## 5. Operasional

```bash
make deploy-logs      # docker compose logs -f backend
make deploy-restart   # restart backend + web
make deploy-backend   # rebuild + up ulang db + backend saja
make deploy-down      # stop semua (volume db-data/uploads tetap ada)
docker compose exec db mariadb -u root -p -e "SHOW TABLES FROM yaw;"
```

Backup data: `docker run --rm -v yaw_db-data:/data -v $PWD:/b alpine tar czf /b/db-backup.tgz /data`
Uploads: `docker run --rm -v yaw_uploads:/data -v $PWD:/b alpine tar czf /b/uploads-backup.tgz /data`
(Nama volume aktual: cek `docker volume ls`; prefix mengikuti nama folder project.)

## 6. TLS

nginx di container hanya listen port 80. Terminasi TLS di depannya, mis.
reverse proxy host / CDN. Contoh cepat di host (butuh nginx + certbot di host):

```nginx
server {
    listen 443 ssl;
    server_name <domain>;
    ssl_certificate /etc/letsencrypt/live/<domain>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<domain>/privkey.pem;
    location / { proxy_pass http://127.0.0.1:80; proxy_set_header Host $host; proxy_set_header X-Forwarded-Proto https; }
}
```

## 7. Update flow

```bash
cd ~/yaw && git pull   # folder checkout repo di VPS
make deploy-web     # bila frontend berubah (API_BASE_URL ikut ke-bake ulang)
make deploy-up      # rebuild image backend bila perlu + restart semua
```
