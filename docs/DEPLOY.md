# YAW — Deploy Podman (Compose: db + backend + web)

Panduan ringkas Bahasa Indonesia untuk VPS Linux (Ubuntu).
Satu `podman compose up` menjalankan MariaDB 11.4, backend Node, dan nginx
yang menyajikan Flutter web + proxy `/api/` dan `/uploads/` ke backend.
Host hanya butuh **podman** + **git** + **curl** — tanpa Flutter
(build web dikerjakan di mesin dev, diambil via GitHub Release),
tanpa systemd unit manual, nginx host, maupun MariaDB native.
Podman daemonless dan bisa jalan rootless.

## 1. Prasyarat (sebagai user root di VPS)

```bash
apt update && apt install -y podman podman-compose curl git
podman --version          # butuh Podman 4.1+
podman compose version    # bila gagal, pakai `podman-compose` (lihat §8)
systemctl enable --now podman.socket   # socket rootful untuk `podman compose`
```

Sebagai root, bind port 80 dan akses socket tidak jadi masalah
(tanpa sysctl tambahan, tanpa sudo di perintah mana pun).

Flutter hanya dibutuhkan di **mesin dev** (untuk `make deploy-web` +
`make release-web`): install SDK stable + `gh` (GitHub CLI, sudah login).

<details>
<summary>Catatan bila deploy sebagai user biasa (bukan root)</summary>

- `podman compose` rootless butuh user socket:
  `systemctl --user enable --now podman.socket` +
  `loginctl enable-linger $USER`.
- User biasa tidak boleh bind port < 1024 — sekali saja sebagai admin:
  `echo 'net.ipv4.ip_unprivileged_port_start=80' > /etc/sysctl.d/99-podman.conf && sysctl --system`.
</details>

## 2. Env deploy

```bash
cp .env.podman.example .env   # lalu isi nilai CHANGE_ME
```

Isi penting: `DB_PASSWORD` + `DB_ROOT_PASSWORD` (acak, `openssl rand -base64 24`),
`JWT_SECRET` 32+ karakter acak (`openssl rand -base64 48`),
`CORS_ORIGIN=https://<domain>` dan `API_BASE_URL=https://<domain>/api/v1`
(wajib sama persis dengan URL yang dibuka user — di-bake ke web saat build).

Catatan: `DB_HOST` harus tetap `db` (nama service compose); container backend
selalu listen di port internal `3002` (`APP_PORT` hanya mengatur port host).

## 3. Build + Release (di mesin dev), fetch + up (di VPS)

Hasil build web **tidak di-commit** — dipublish sebagai asset GitHub Release
(`yaw-web-v*.tar.gz`, ~36 MB termasuk canvaskit lokal), VPS fetch + extract:

```bash
# --- di mesin dev ---
cp .env.podman.example .env   # isi API_BASE_URL domain produksi
make deploy-web    # flutter build web -o deploy/web (API_BASE_URL di-bake) + hapus *.symbols
rm -f .env
make release-web   # tarball + `gh release create` (tag default v<versi-pubspec>, override: VERSION=vX)
```

```bash
# --- di VPS ---
git pull
cp .env.podman.example .env   # sekali saja, lalu isi secret (DB_*, JWT_SECRET)
make deploy-fetch-web  # download + extract release terbaru ke deploy/web (butuh gh/curl)
make deploy-up         # podman compose up -d --build
podman compose ps
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
make deploy-logs      # podman compose logs -f backend
make deploy-restart   # restart backend + web
make deploy-backend   # rebuild + up ulang db + backend saja
make deploy-down      # stop semua (volume db-data/uploads tetap ada)
podman compose exec db mariadb -u root -p -e "SHOW TABLES FROM yaw;"
```

Backup data: `podman run --rm -v yaw_db-data:/data -v $PWD:/b alpine tar czf /b/db-backup.tgz /data`
Uploads: `podman run --rm -v yaw_uploads:/data -v $PWD:/b alpine tar czf /b/uploads-backup.tgz /data`
(Nama volume aktual: cek `podman volume ls`; prefix mengikuti nama folder project.)

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
# --- di mesin dev (bila frontend berubah) ---
make deploy-web release-web   # API_BASE_URL ikut ke-bake ulang; tag naik bila versi pubspec naik

# --- di VPS ---
cd ~/yaw && git pull           # folder checkout repo di VPS
rm -rf deploy/web && make deploy-fetch-web  # ambil build terbaru (lewati bila versi sama)
make deploy-up      # rebuild image backend bila perlu + restart semua
```

## 8. Bila `podman compose` tidak tersedia

Podman lama (< 4.1) tidak punya subcommand `compose` bawaan. Pakai paket
`podman-compose` (Python) sebagai pengganti 1:1:

```bash
apt install podman-compose  # atau: pip install podman-compose
podman-compose up -d --build
```

Semua target `make deploy-*` memakai `podman compose`; bila memakai
`podman-compose`, jalankan perintah compose manual sesuai contoh di atas.
