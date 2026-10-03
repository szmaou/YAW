# YAW — Flutter + Express + MariaDB (deploy Podman Compose + testing)
# `make help` lists all targets. Fokus: deploy Podman + testing.
# Dev lokal: MariaDB native (systemctl), npm (backend), flutter (app).
# Deploy target di bawah ini jalan DI VPS setelah git pull (butuh podman + flutter).

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
	@echo "Deploy:   cp .env.podman.example .env (isi secret) && make deploy-web deploy-up"
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

# ── deploy (production Podman Compose: db + backend + web, jalan DI VPS) ──
.PHONY: deploy-backend deploy-web deploy-up deploy-down deploy-restart deploy-logs deploy-verify

deploy-web: ## Build Flutter web ke deploy/web + commit (di mesin dev; butuh API_BASE_URL dari .env)
	@if [ -f .env ]; then set -a; . ./.env; set +a; fi; \
	if [ -z "$${API_BASE_URL:-}" ]; then echo "API_BASE_URL kosong — salin .env.podman.example ke .env lalu isi API_BASE_URL"; exit 1; fi; \
	flutter build web --release --no-web-resources-cdn -o deploy/web --dart-define=API_BASE_URL=$${API_BASE_URL}
	# Hapus file .symbols (debug, ~6MB) — tidak dibutuhkan runtime:
	find deploy/web -name '*.symbols' -delete
	@du -sh deploy/web

deploy-backend: ## Build + jalankan ulang service backend+db (VPS)
	podman compose up -d --build db backend

deploy-up: ## Jalankan semua service (db+backend+web) (VPS)
	@if [ ! -f .env ]; then echo ".env tidak ada — salin dulu: cp .env.podman.example .env"; exit 1; fi
	@if [ ! -f deploy/web/index.html ]; then echo "deploy/web kosong — di mesin dev jalan dulu: make deploy-web + commit + push, lalu git pull di sini"; exit 1; fi
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
