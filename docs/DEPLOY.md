# YAW — Deploy Native VPS (systemd + nginx + MariaDB)

Panduan ringkas Bahasa Indonesia untuk VPS Linux (Ubuntu).
systemd dipilih atas pm2 karena backend hanya satu proses Node — auto-restart + journalctl tanpa dependensi tambahan.

## 1. Prasyarat

```bash
node --version   # butuh Node 20+
nginx -v
mariadb --version
certbot --version
```

Install bila belum ada: `sudo apt install nodejs nginx mariadb-server certbot python3-certbot-nginx`.

## 2. Setup DB native

```bash
sudo systemctl enable --now mariadb
sudo mariadb -u root -e "CREATE DATABASE IF NOT EXISTS yaw CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'yaw_user'@'%' IDENTIFIED BY 'yaw123'; CREATE USER IF NOT EXISTS 'yaw_user'@'localhost' IDENTIFIED BY 'yaw123'; GRANT ALL ON yaw.* TO 'yaw_user'@'%'; GRANT ALL ON yaw.* TO 'yaw_user'@'localhost'; FLUSH PRIVILEGES;"
mariadb -u yaw_user -p'yaw123' -h 127.0.0.1 -e "SHOW TABLES FROM yaw;"
```

## 3. Env backend prod

```bash
cp .env.prod.example /opt/yaw/backend/.env   # lalu isi nilai CHANGE_ME
```

Isi penting: `DB_HOST=127.0.0.1`, `DB_PORT=3306`,
`UPLOAD_PATH=/var/lib/yaw/uploads` (absolut; buat dir + chown www-data),
`JWT_SECRET` 32+ karakter acak (`openssl rand -base64 48`),
`CORS_ORIGIN=https://<domain>` dan `API_BASE_URL=https://<domain>/api/v1`.

## 4. Build + install backend (systemd)

```bash
cd /opt/yaw/backend && npm ci && npm run build
sudo cp deploy/yaw-backend.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now yaw-backend
journalctl -u yaw-backend -f
```

## 5. Build web

```bash
flutter build web --release --dart-define=API_BASE_URL=https://<domain>/api/v1
sudo rm -rf /var/www/yaw-web && sudo cp -r build/web /var/www/yaw-web
```

## 6. nginx + TLS

```bash
sudo cp deploy/nginx-yaw.conf /etc/nginx/sites-available/yaw
sudo ln -sf /etc/nginx/sites-available/yaw /etc/nginx/sites-enabled/yaw
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d <domain>
```

## 7. Verifikasi

```bash
curl -s http://localhost:3002/api/health
curl -s https://<domain>/api/health
curl -s -X POST https://<domain>/api/v1/auth/login -H 'Content-Type: application/json' -d '{"email":"admin@yaw.id","password":"admin123"}'
```

Login seed: `admin@yaw.id / admin123` (ganti setelah masuk).

## 8. Update flow

```bash
cd /opt/yaw && git pull
# backend berubah:
cd backend && npm ci && npm run build && sudo systemctl restart yaw-backend
# web berubah:
flutter build web --release --dart-define=API_BASE_URL=https://<domain>/api/v1
sudo rm -rf /var/www/yaw-web && sudo cp -r build/web /var/www/yaw-web
```

## Lampiran: setup tanpa hak admin (user-space)

Varian ini tidak memakai `systemd` sistem, `/opt/yaw`, `/var/lib/yaw/uploads`,
maupun port 80/443 — semua di `$HOME`. Jalankan sebagai user biasa:

```bash
./scripts/setup-userspace.sh                  # backend saja
./scripts/setup-userspace.sh --with-web       # + build Flutter web ke $HOME/yaw-web
./scripts/setup-userspace.sh --with-web --api-base-url=https://<domain>/api/v1
```

Skrip mengurus: cek prasyarat (tanpa instalasi), clone/pull ke `$HOME/yaw`,
salin `backend/.env.example` ke `backend/.env` (tidak menimpa bila sudah ada,
dengan `UPLOAD_PATH=$HOME/yaw-uploads`), `npm ci` + `npm run build`, lalu jalan
via `systemd --user` bila tersedia (unit di `~/.config/systemd/user/`) atau
fallback `nohup` (`$HOME/yaw/backend/backend.log`), dan cek
`http://localhost:3002/api/health`.

Batasan (disengaja, karena tanpa hak admin):

- Pembuatan database/user diserahkan ke admin mesin (lihat langkah 2 di atas);
  migrasi tabel + seed tetap otomatis saat backend start (initDb).
- Tidak ada port 80/443 (butuh proses hak admin) — web diserve dari port biasa,
  mis. `cd $HOME/yaw-web && python3 -m http.server 8080`.
- Autostart penuh butuh sesi lingering (`loginctl enable-linger $USER` oleh admin).
