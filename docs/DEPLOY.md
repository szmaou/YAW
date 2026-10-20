# YAW — Deploy Docker (Compose: db + backend + web)

Panduan ringkas Bahasa Indonesia untuk VPS Linux (Ubuntu).
Satu `docker compose up` menjalankan MariaDB 11.4, backend Node, dan nginx
yang menyajikan Flutter web + proxy `/api/` dan `/uploads/` ke backend.
Host hanya butuh **docker** + **git** + **curl** — tanpa Flutter
(build web dikerjakan di mesin dev, diambil via GitHub Release),
tanpa systemd unit manual, nginx host, maupun MariaDB native.
Docker rootless — daemon jalan sebagai user biasa.

## 1. Prasyarat VPS

```bash
# Sekali saja, sebagai user biasa (install Docker Engine rootless):
sudo apt update && sudo apt install -y curl git uidmap dbus-user-session
curl -fsSL https://get.docker.com/rootless | sh
systemctl --user enable --now docker
loginctl enable-linger $USER              # daemon + container tetap hidup tanpa sesi login

# Cek (tambahkan PATH bila binary di ~/bin):
docker --version
docker compose version    # bila gagal, lihat §9 (docker-compose v1)
```

Stack **rootless**: semua port host >1024 (nginx web di `WEB_PORT` default
`8080`, backend `3002`) — tidak perlu sysctl maupun sudo lagi (setelah
install di atas). Bila tetap mau port 80, opsional sekali saja:
`echo 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee /etc/sysctl.d/99-docker.conf && sudo sysctl --system`,
lalu set `WEB_PORT=80` di `.env`.

Flutter hanya dibutuhkan di **mesin dev** (untuk `make deploy-web` +
`make release-web`): install SDK stable + `gh` (GitHub CLI, sudah login).

<details>
<summary>Catatan migrasi dari deploy Podman lama</summary>

Sebelumnya panduan ini berjalan dengan Podman. Bila VPS masih punya stack lama:

- jalankan di akun deploy lama: `podman compose down`, `systemctl --user disable --now yaw-compose.service`, `systemctl --user disable --now podman.socket`,
- export data bila perlu (lihat §5 backup), lalu biarkan stack Docker baru
  membuat volume baru (db seed ulang login `admin@yaw.id/admin123`).
</details>

## 2. Env deploy

```bash
cp .env.docker.example .env   # lalu isi nilai CHANGE_ME
```

Isi penting: `DB_PASSWORD` + `DB_ROOT_PASSWORD` (acak, `openssl rand -base64 24`),
`JWT_SECRET` 32+ karakter acak (`openssl rand -base64 48`),
`CORS_ORIGIN=https://<domain>` dan `API_BASE_URL=https://<domain>/api/v1`
(wajib sama persis dengan URL yang dibuka user — di-bake ke web saat build).
`WEB_PORT` (default 8080) = port host nginx web; rootless tetap di atas 1024.

Catatan: `DB_HOST` harus tetap `db` (nama service compose); container backend
selalu listen di port internal `3002` (`APP_PORT` hanya mengatur port host).

## 3. Build + Release (di mesin dev), fetch + up (di VPS)

Hasil build web **tidak di-commit** — dipublish sebagai asset GitHub Release
(`yaw-web-v*.tar.gz`, ~36 MB termasuk canvaskit lokal), VPS fetch + extract:

```bash
# --- di mesin dev ---
cp .env.docker.example .env   # isi API_BASE_URL domain produksi
make deploy-web    # flutter build web -o deploy/web (API_BASE_URL di-bake) + hapus *.symbols
rm -f .env
make release-web   # tarball + `gh release create` (tag default v<versi-pubspec>, override: VERSION=vX)
```

```bash
# --- di VPS ---
git pull
cp .env.docker.example .env   # sekali saja, lalu isi secret (DB_*, JWT_SECRET)
make deploy-fetch-web  # download + extract release terbaru ke deploy/web (butuh gh/curl)
make deploy-up         # docker compose up -d --build
docker compose ps
```

Boot pertama: service `db` dibuat dari image `mariadb:11.4` (database + user
dibuat otomatis dari `DB_*`), lalu backend menjalankan migrasi + seed otomatis
(`initDb`): login awal `admin@yaw.id / admin123` (ganti setelah masuk).

## 4. Verifikasi

```bash
make deploy-verify
curl -s -X POST http://localhost:8080/api/v1/auth/login -H 'Content-Type: application/json' -d '{"email":"admin@yaw.id","password":"admin123"}'
```

(Web di port `WEB_PORT` — default `8080`. Ganti sesuai `.env` bila diubah.)

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
    location / { proxy_pass http://127.0.0.1:8080; proxy_set_header Host $host; proxy_set_header X-Forwarded-Proto https; }
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

## 8. Auto-start saat boot (systemd user unit)

Stack naik otomatis setelah VPS reboot dengan unit rootless yang sudah
disediakan: `deploy/yaw-docker-compose.service` (unit **user** — tanpa sudo):

```bash
mkdir -p ~/.config/systemd/user
cp deploy/yaw-docker-compose.service ~/.config/systemd/user/
# edit WorkingDirectory ke folder checkout repo di VPS (mis. /home/<user>/yaw)
vim ~/.config/systemd/user/yaw-docker-compose.service
systemctl --user daemon-reload
systemctl --user enable --now yaw-docker-compose.service
loginctl enable-linger $USER   # sekali, penting: unit hidup tanpa sesi login
systemctl --user status yaw-docker-compose.service   # cek active (exited) + docker compose ps
```

Restart env `.env` tidak ikut berubah saat boot. `git pull` **tidak** dijalankan
unit (deploy tetap manual lewat §7 agar tak ada kejutan saat reboot); yang
dilakukan unit hanyalah `docker compose up -d --build`.

## 9. Bila plugin `docker compose` tidak tersedia

Docker lama (< 20.10 / tanpa plugin compose) tidak punya subcommand `compose`.
Pakai `docker-compose` v1 sebagai pengganti 1:1:

```bash
pip install docker-compose   # atau binary release v2 dari docker/compose
docker-compose up -d --build
```

Semua target `make deploy-*` memakai `docker compose`; bila memakai
`docker-compose`, jalankan perintah compose manual sesuai contoh di atas.
