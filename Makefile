# YAW — Flutter + Express + MariaDB (deploy Podman Compose + testing)
# `make help` lists all targets. Fokus: deploy Podman + testing.
# Dev lokal: MariaDB native (systemctl), npm (backend), flutter (app).
# Deploy: build web + Release di mesin dev (butuh flutter + gh),
#   jalan DI VPS setelah fetch release (butuh podman + git + curl).

SHELL := /bin/bash
.DEFAULT_GOAL := help

BACKEND_DIR := backend

# ── help ──────────────────────────────────────────────────────────
.PHONY: help
help: ## Show this help
	@echo "YAW — make targets (deploy Podman + testing)"
	@echo ""
	@grep -E '^[a-zA-Z0-9_/-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Deploy:   (dev) make deploy-web release-web  |  (VPS) make deploy-fetch-web deploy-up"
	@echo "  web: build→tarball→GitHub Release di dev; VPS fetch release (tanpa flutter)"
	@echo "Env dev:  cp backend/.env.example backend/.env (isi sesuai lokal)"
	@echo "Testing:  make verify  (tsc + dart analyze, 0 errors)  |  make app-test"

# ── testing ───────────────────────────────────────────────────────
.PHONY: verify backend-typecheck app-analyze app-test backend-health

verify: backend-typecheck app-analyze ## tsc + dart analyze (0 errors; infos ok)
	@echo "verify done — backend tsc + dart analyze passed (infos are ok, errors must be 0)."

backend-typecheck: ## Typecheck backend (EXIT 0)
	cd $(BACKEND_DIR) && ./node_modules/.bin/tsc --noEmit

app-analyze: ## Dart analyze (direct SDK; ~70 infos clean, 0 errors pass)
	/opt/flutter/bin/cache/dart-sdk/bin/dart analyze

app-test: ## Flutter tests
	flutter test

backend-health: ## Curl health + login (butuh backend jalan)
	@curl -s http://localhost:3002/api/health | head -c 500; echo
	@curl -s -X POST http://localhost:3002/api/v1/auth/login -H 'Content-Type: application/json' -d '{"email":"admin@yaw.id","password":"admin123"}' | head -c 700; echo

# ── deploy (production Podman Compose: db + backend + web) ──
# Web tidak di-commit: dev build → publish ke GitHub Release → VPS fetch.
.PHONY: deploy-backend deploy-web release-web deploy-fetch-web deploy-up deploy-down deploy-restart deploy-logs deploy-verify

deploy-web: ## Build Flutter web ke deploy/web (di mesin dev; butuh API_BASE_URL dari .env)
	@if [ -f .env ]; then set -a; . ./.env; set +a; fi; \
	if [ -z "$${API_BASE_URL:-}" ]; then echo "API_BASE_URL kosong — salin .env.podman.example ke .env lalu isi API_BASE_URL"; exit 1; fi; \
	flutter build web --release --no-web-resources-cdn -o deploy/web --dart-define=API_BASE_URL=$${API_BASE_URL}
	# Hapus file .symbols (debug, ~6MB) — tidak dibutuhkan runtime:
	find deploy/web -name '*.symbols' -delete
	@du -sh deploy/web

release-web: ## Tarball deploy/web + publish GitHub Release (dev; butuh gh login; VERSION=vX default dari pubspec)
	@if [ ! -f deploy/web/index.html ]; then echo "deploy/web kosong — jalan dulu: make deploy-web"; exit 1; fi
	@TAG="$(VERSION)"; [ -z "$$TAG" ] && TAG="v$$(grep '^version:' pubspec.yaml | awk '{print $$2}')"; \
	tar czf "/tmp/yaw-web-$${TAG}.tar.gz" -C deploy web && \
	gh release create "$${TAG}" "/tmp/yaw-web-$${TAG}.tar.gz" --title "YAW $${TAG} (web)" --notes "Build web Flutter (isi deploy/web). API_BASE_URL di-bake saat build." && \
	rm -f "/tmp/yaw-web-$${TAG}.tar.gz"

deploy-fetch-web: ## Download + extract build web dari GitHub Release terbaru (VPS; butuh gh/curl)
	@if [ -f deploy/web/index.html ]; then echo "deploy/web sudah ada — hapus dulu bila mau fetch ulang"; exit 0; fi; \
	if command -v gh >/dev/null 2>&1; then gh release download --pattern 'yaw-web-*.tar.gz' --dir /tmp; else \
	  REPO=$$(git config --get remote.origin.url | sed -E 's#.*github\.com[:/]##; s#\.git$$##'); \
	  [ -z "$$REPO" ] && { echo "gagal baca remote origin — cek 'git remote -v'"; exit 1; }; \
	  TAG=$$(git ls-remote --tags origin 2>/dev/null | grep -o 'refs/tags/v[^^{]*' | sed 's#refs/tags/##' | sort -V | tail -1); \
	  [ -z "$$TAG" ] && { echo "gagal baca tags dari origin ($$REPO) — cek koneksi git / pasang gh: apt install gh && gh auth login"; exit 1; }; \
	  echo "fetch yaw-web-$${TAG}.tar.gz dari $${REPO} ..."; \
	  curl -fSL "https://github.com/$${REPO}/releases/download/$${TAG}/yaw-web-$${TAG}.tar.gz" -o /tmp/yaw-web-fetch.tar.gz || \
	  { echo "download gagal — cek koneksi ke github.com / pasang gh: apt install gh && gh auth login"; exit 1; }; fi; \
	TGZ=$$(ls -t /tmp/yaw-web-*.tar.gz 2>/dev/null | head -1); \
	[ -n "$$TGZ" ] || { echo "file tarball tidak ditemukan di /tmp — download mungkin gagal"; exit 1; }; \
	echo "extract $$TGZ ..."; \
	mkdir -p deploy && tar --extract --gzip --file="$$TGZ" --directory=deploy && rm -f "$$TGZ" && \
	ls deploy/web/index.html && du -sh deploy/web

deploy-backend: ## Build + jalankan ulang service backend+db (VPS)
	podman compose up -d --build db backend

deploy-up: ## Jalankan semua service (db+backend+web) (VPS)
	@if [ ! -f .env ]; then echo ".env tidak ada — salin dulu: cp .env.podman.example .env"; exit 1; fi
	@if [ ! -f deploy/web/index.html ]; then echo "deploy/web kosong — di mesin dev: make deploy-web release-web; di sini: make deploy-fetch-web"; exit 1; fi
	podman compose up -d --build

deploy-down: ## Hentikan semua service (data db-data/uploads tetap ada)
	podman compose down

deploy-restart: ## Restart service backend + web (VPS)
	podman compose restart backend web

deploy-logs: ## Follow log backend (VPS)
	podman compose logs -f backend

deploy-verify: ## Curl health via nginx + backend langsung + petunjuk login seed (VPS)
	curl -s http://localhost/api/health | head -c 500; echo
	curl -s http://localhost:3002/api/health | head -c 500; echo
	@echo "Login seed: admin@yaw.id / admin123 (POST /api/v1/auth/login, ganti setelah masuk)."
