#!/usr/bin/env bash
# YAW — satu-satunya entry deploy production (Docker-only).
# Pakai: ./scripts/deploy.sh [up|build|down|logs|verify|web-rebuild]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ENV_FILE=".env.prod"
COMPOSE="docker compose -f docker-compose.prod.yml --env-file ${ENV_FILE}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[deploy] .env.prod tidak ditemukan."
  echo "[deploy] Salin contoh lalu isi secret: cp .env.prod.example .env.prod"
  exit 1
fi

# Muat .env.prod agar API_BASE_URL tersedia sebagai build-arg web.
set -a
# shellcheck disable=SC1091
source "$ENV_FILE"
set +a

if [[ -z "${API_BASE_URL:-}" ]]; then
  echo "[deploy] API_BASE_URL kosong di .env.prod — isi dulu (mis. https://<domain>/api/v1)."
  exit 1
fi
if [[ -z "${JWT_SECRET:-}" ]]; then
  echo "[deploy] JWT_SECRET kosong di .env.prod — isi dulu (min 32 karakter acak)."
  exit 1
fi

CMD="${1:-up}"

case "$CMD" in
  up)
    echo "[deploy] Build + up production stack..."
    $COMPOSE up -d --build
    $COMPOSE ps
    echo "[deploy] Selesai. Cek: ./scripts/deploy.sh verify"
    ;;
  build)
    echo "[deploy] Build image production (tanpa up)..."
    $COMPOSE build
    echo "[deploy] Build selesai."
    ;;
  down)
    echo "[deploy] Menurunkan stack production (volume dipertahankan)..."
    $COMPOSE down
    ;;
  logs)
    echo "[deploy] Mengikuti log backend + web (Ctrl+C untuk keluar)..."
    $COMPOSE logs -f yaw-backend yaw-web
    ;;
  verify)
    echo "[deploy] Verifikasi backend via container..."
    if docker exec yaw-prod-backend node -e "fetch('http://localhost:3002/api/health').then(async r=>{console.log(await r.text());process.exit(r.ok?0:1)}).catch(e=>{console.error(e.message);process.exit(1)})"; then
      echo "[deploy] OK — /api/health 200."
    else
      echo "[deploy] GAGAL — backend tidak sehat. Lihat: ./scripts/deploy.sh logs"
      exit 1
    fi
    echo "[deploy] Dari host, buka http://localhost/ (web) — API di http://localhost/api/health."
    echo "[deploy] Login seed bawaan: admin@yaw.id / admin123 (ganti setelah masuk)."
    ;;
  web-rebuild)
    echo "[deploy] Rebuild + restart yaw-web saja..."
    $COMPOSE build yaw-web
    $COMPOSE up -d yaw-web
    $COMPOSE ps
    ;;
  *)
    echo "Pakai: ./scripts/deploy.sh [up|build|down|logs|verify|web-rebuild]"
    exit 1
    ;;
esac
