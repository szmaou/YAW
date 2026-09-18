#!/usr/bin/env bash
# YAW — setup user-space dari 0 TANPA hak admin (semua di $HOME).
# Semua langkah di bawah berjalan sebagai user biasa: tidak ada instalasi
# paket sistem, tidak ada tulis ke luar $HOME, tidak ada bind port <1024.
# Pakai: ./scripts/setup-userspace.sh [--with-web] [--api-base-url URL]
#   --with-web         : ikut build Flutter web ke $HOME/yaw-web (butuh flutter)
#   --api-base-url URL : API publik untuk web build (default http://localhost:3002/api/v1)
set -euo pipefail

APP_ROOT="$HOME/yaw"
BACKEND_DIR="$APP_ROOT/backend"
UPLOAD_DIR="$HOME/yaw-uploads"
WEB_DIR="$HOME/yaw-web"
UNIT_DIR="$HOME/.config/systemd/user"
UNIT_FILE="$UNIT_DIR/yaw-backend.service"
REPO_URL="git@github.com:szmaou/YAW.git"
APP_PORT="${APP_PORT:-3002}"
API_BASE_URL_DEFAULT="http://localhost:${APP_PORT}/api/v1"

WITH_WEB=0
API_BASE_URL=""

for arg in "$@"; do
  case "$arg" in
    --with-web) WITH_WEB=1 ;;
    --api-base-url=*) API_BASE_URL="${arg#*=}" ;;
    --api-base-url)
      echo "[setup] --api-base-url butuh nilai: --api-base-url=https://<domain>/api/v1" >&2
      exit 1
      ;;
    -h|--help)
      echo "Pakai: ./scripts/setup-userspace.sh [--with-web] [--api-base-url URL]"
      exit 0
      ;;
    *)
      echo "[setup] Argumen tak dikenal: $arg (lihat --help)" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$API_BASE_URL" && -n "${API_BASE_URL_ENV:-}" ]]; then
  API_BASE_URL="$API_BASE_URL_ENV"
fi
if [[ -z "$API_BASE_URL" ]]; then
  API_BASE_URL="$API_BASE_URL_DEFAULT"
fi

log() { echo "[setup] $*"; }
fail() { echo "[setup] GAGAL: $*" >&2; exit 1; }

# ── 1. Prasyarat (cek saja, tidak menginstal apa pun) ──────────────────────
log "Cek prasyarat (node 20+, npm, curl wajib; flutter + mariadb opsional)..."

command -v node >/dev/null 2>&1 || fail "node tidak ditemukan. Instal Node.js 20+ dulu (nvm/nodejs.org), lalu ulangi."
NODE_MAJOR="$(node -p "process.versions.node.split('.')[0]")"
if [[ "$NODE_MAJOR" -lt 20 ]]; then
  fail "Node versi $(node --version) terlalu lama — butuh Node 20+."
fi
log "node $(node --version) OK."

command -v npm >/dev/null 2>&1 || fail "npm tidak ditemukan (biasanya sepaket dengan Node)."
log "npm $(npm --version) OK."

command -v curl >/dev/null 2>&1 || fail "curl tidak ditemukan. Minta admin mesin menginstalnya, atau instal manual di $HOME lalu tambahkan ke PATH."
log "curl OK."

if command -v flutter >/dev/null 2>&1; then
  log "flutter $(flutter --version 2>/dev/null | head -n1) tersedia (build web dimungkinkan)."
  HAVE_FLUTTER=1
else
  log "flutter tidak ada — langkah --with-web akan dilewati (backend tetap jalan)."
  HAVE_FLUTTER=0
fi

if command -v mariadb >/dev/null 2>&1; then
  HAVE_DBCLIENT="mariadb"
elif command -v mysql >/dev/null 2>&1; then
  HAVE_DBCLIENT="mysql"
else
  HAVE_DBCLIENT=""
  log "klien mariadb/mysql tidak ada — cek koneksi DB dilewati, panduan manual dicetak di langkah 4."
fi

# ── 2. Lokasi user-space ───────────────────────────────────────────────────
log "Lokasi user-space: APP_ROOT=$APP_ROOT UPLOAD_DIR=$UPLOAD_DIR WEB_DIR=$WEB_DIR"

if [[ -d "$APP_ROOT/.git" ]]; then
  log "Repo sudah ada di $APP_ROOT — git pull..."
  git -C "$APP_ROOT" pull --ff-only || log "git pull gagal (lanjut dengan kode lokal)."
elif [[ -e "$APP_ROOT" ]]; then
  fail "$APP_ROOT ada tapi bukan repo git. Pindahkan dulu, lalu ulangi."
else
  log "Clone repo ke $APP_ROOT ..."
  git clone "$REPO_URL" "$APP_ROOT" || fail "git clone gagal. Cek akses git/SSH ke $REPO_URL."
fi

[[ -f "$BACKEND_DIR/package.json" ]] || fail "$BACKEND_DIR/package.json tidak ada — repo tidak lengkap."
[[ -f "$BACKEND_DIR/.env.example" ]] || fail "$BACKEND_DIR/.env.example tidak ada — repo tidak lengkap."

# ── 3. Env backend ($BACKEND_DIR/.env; tidak timpa bila sudah ada) ─────────
if [[ -f "$BACKEND_DIR/.env" ]]; then
  log ".env sudah ada — tidak ditimpa."
else
  log "Salin backend/.env.example -> backend/.env ..."
  cp "$BACKEND_DIR/.env.example" "$BACKEND_DIR/.env"
fi

# Paksa nilai user-space (portabel: sed dasar, tanpa GNU extension).
set_kv() { # $1=file $2=key $3=value
  local file="$1" key="$2" val="$3" tmp
  tmp="$(mktemp)"
  awk -v k="$key" -v v="$val" '
    BEGIN { done=0 }
    $0 ~ "^" k "=" { print k "=" v; done=1; next }
    { print }
    END { if (!done) print k "=" v }
  ' "$file" > "$tmp" && mv "$tmp" "$file"
}
set_kv "$BACKEND_DIR/.env" "DB_HOST" "127.0.0.1"
set_kv "$BACKEND_DIR/.env" "DB_PORT" "3306"
set_kv "$BACKEND_DIR/.env" "UPLOAD_PATH" "$UPLOAD_DIR"

log ".env siap di $BACKEND_DIR/.env (DB_HOST=127.0.0.1 DB_PORT=3306 UPLOAD_PATH=$UPLOAD_DIR)."
log "Tinggal edit manual bila perlu: DB_PASSWORD / JWT_SECRET / CORS_ORIGIN / API_BASE_URL."
log "Contoh JWT acak: openssl rand -base64 48  (bila openssl tersedia)."

# Muat .env agar langkah DB + build tahu nilainya (tanpa mengekspor rahasia ke log).
set -a
# shellcheck disable=SC1091
source "$BACKEND_DIR/.env"
set +a
DB_USER="${DB_USER:-yaw_user}"
DB_NAME="${DB_NAME:-yaw}"
APP_PORT="${APP_PORT:-3002}"

# ── 4. DB (hanya cek koneksi — pembuatan DB oleh admin, auto-migrate oleh backend)
print_db_guide() {
  cat <<EOF
[setup] ── Panduan DB untuk admin mesin ─────────────────────────────
[setup] Skrip ini TIDAK membuat database sendiri. Minta admin menjalankan:
[setup]
[setup]   mariadb -u root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '<password>'; CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '<password>'; GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'%'; GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;"
[setup]
[setup] Lalu samakan <password> dengan DB_PASSWORD di $BACKEND_DIR/.env
[setup] dan start ulang backend. Migrasi tabel + seed admin (admin@yaw.id/admin123,
[setup] user@yaw.id/user123) berjalan otomatis saat backend start (initDb).
[setup] ─────────────────────────────────────────────────────────────
EOF
}

if [[ -n "$HAVE_DBCLIENT" ]]; then
  log "Cek koneksi DB via $HAVE_DBCLIENT ($DB_USER@127.0.0.1:3306)..."
  if "$HAVE_DBCLIENT" -u "$DB_USER" -h 127.0.0.1 -P 3306 -e "SHOW TABLES FROM ${DB_NAME};" >/dev/null 2>&1; then
    log "Koneksi DB OK — database $DB_NAME bisa diakses."
  elif "$HAVE_DBCLIENT" -u "$DB_USER" -h 127.0.0.1 -P 3306 -p"${DB_PASSWORD:-}" -e "SHOW TABLES FROM ${DB_NAME};" >/dev/null 2>&1; then
    log "Koneksi DB OK (dengan password) — database $DB_NAME bisa diakses."
  else
    log "Koneksi DB gagal — backend nanti tetap start (health 200, rute DB 503) sampai DB siap."
    print_db_guide
  fi
else
  print_db_guide
fi

# ── 5. Backend: install + build ────────────────────────────────────────────
log "Install dependensi backend (npm ci, fallback npm install)..."
cd "$BACKEND_DIR"
if npm ci 2>/dev/null; then
  log "npm ci OK."
else
  log "npm ci gagal (umum bila lockfile beda platform) — fallback npm install..."
  npm install
fi

log "Build backend (npm run build)..."
npm run build
[[ -f "$BACKEND_DIR/dist/app.js" ]] || fail "dist/app.js tidak terbentuk setelah build."
log "Build OK: $BACKEND_DIR/dist/app.js ada."

# ── 6. Direktori uploads ───────────────────────────────────────────────────
mkdir -p "$UPLOAD_DIR"
log "Upload dir siap: $UPLOAD_DIR"

# ── 7. Jalankan backend TANPA service sistem ───────────────────────────────
NODE_BIN="$(command -v node)"
start_fallback() {
  log "Fallback: jalankan via nohup (tanpa service manager)..."
  cd "$BACKEND_DIR"
  if pgrep -f "node .*yaw/backend/dist/app.js" >/dev/null 2>&1; then
    log "Proses backend lama masih jalan — hentikan dulu bila ingin start baru:"
    log "  pkill -f 'node .*yaw/backend/dist/app.js'"
  fi
  nohup "$NODE_BIN" "$BACKEND_DIR/dist/app.js" > "$BACKEND_DIR/backend.log" 2>&1 &
  echo "$!" > "$BACKEND_DIR/backend.pid"
  log "Backend jalan via nohup, PID $(cat "$BACKEND_DIR/backend.pid")."
  log "Lihat log: tail -f $BACKEND_DIR/backend.log"
  log "Hentikan:  kill \$(cat $BACKEND_DIR/backend.pid)"
}

USE_USER_SERVICE=0
if command -v systemctl >/dev/null 2>&1 && systemctl --user daemon-reload >/dev/null 2>&1; then
  USE_USER_SERVICE=1
fi

if [[ "$USE_USER_SERVICE" -eq 1 ]]; then
  log "systemd user tersedia — pasang unit $UNIT_FILE ..."
  mkdir -p "$UNIT_DIR"
  cat > "$UNIT_FILE" <<EOF
[Unit]
Description=yaw-backend (user-space)
After=network.target

[Service]
Type=simple
WorkingDirectory=$BACKEND_DIR
ExecStart=$NODE_BIN $BACKEND_DIR/dist/app.js
Restart=always
RestartSec=5
Environment=NODE_ENV=production
EnvironmentFile=$BACKEND_DIR/.env
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF
  systemctl --user daemon-reload
  systemctl --user enable --now yaw-backend
  log "Service user aktif. Lihat log: journalctl --user -u yaw-backend -f"
  log "Hentikan: systemctl --user stop yaw-backend  |  Nonaktifkan autostart: systemctl --user disable yaw-backend"
  log "Catatan: autostart user-service butuh sesi lingering (minta admin: loginctl enable-linger \$USER)."
else
  log "systemd user tidak tersedia — pakai fallback nohup."
  start_fallback
fi

# ── 8. Verifikasi ──────────────────────────────────────────────────────────
log "Tunggu ~3 detik lalu cek http://localhost:${APP_PORT}/api/health ..."
sleep 3
if curl -s "http://localhost:${APP_PORT}/api/health"; then
  echo ""
  log "OK — backend sehat."
else
  log "Health check belum OK — backend mungkin masih start / DB belum siap."
fi
if [[ "$USE_USER_SERVICE" -eq 1 ]]; then
  log "Log: journalctl --user -u yaw-backend -f"
else
  log "Log: tail -f $BACKEND_DIR/backend.log"
fi

# ── 9. Opsional: build web ─────────────────────────────────────────────────
if [[ "$WITH_WEB" -eq 1 ]]; then
  if [[ "$HAVE_FLUTTER" -eq 0 ]]; then
    log "--with-web diminta tapi flutter tidak ada — lewati."
  else
    log "Build Flutter web (API_BASE_URL=$API_BASE_URL)..."
    flutter build web --release --dart-define=API_BASE_URL="$API_BASE_URL"
    mkdir -p "$WEB_DIR"
    cp -r "$APP_ROOT/build/web/." "$WEB_DIR/"
    log "Web siap di $WEB_DIR."
    log "Serve dari user-space, misal: cd $WEB_DIR && python3 -m http.server 8080"
    log "Lalu buka http://localhost:8080 (port 80/443 hanya untuk proses hak admin, jadi gunakan port biasa seperti 8080)."
  fi
fi

log "Selesai. Login seed bawaan: admin@yaw.id / admin123 (ganti setelah masuk)."
