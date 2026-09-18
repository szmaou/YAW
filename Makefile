# YAW — Flutter + Express + MariaDB (native VPS deploy + testing)
# `make help` lists all targets. Fokus: deploy native (systemd+nginx) + testing.
# Dev lokal: MariaDB native (systemctl), npm (backend), flutter (app).
# Deploy target di bawah ini jalan DI VPS setelah git pull.

SHELL := /bin/bash
.DEFAULT_GOAL := help

BACKEND_DIR := backend

# ── help ──────────────────────────────────────────────────────────
.PHONY: help
help: ## Show this help
	@echo "YAW — make targets (native deploy + testing)"
	@echo ""
	@grep -E '^[a-zA-Z0-9_/-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Deploy:   cp .env.prod.example /opt/yaw/backend/.env (isi secret) && make deploy-backend deploy-web"
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

# ── deploy (production native: systemd + nginx + MariaDB, jalan DI VPS) ──
.PHONY: deploy-backend deploy-web deploy-restart deploy-logs deploy-verify

deploy-backend: ## Build backend + restart service (VPS)
	cd $(BACKEND_DIR) && npm ci && npm run build && sudo systemctl restart yaw-backend

deploy-web: ## Build web + copy ke /var/www/yaw-web (VPS; butuh API_BASE_URL dari .env.prod)
	@if [ -f /opt/yaw/backend/.env ]; then set -a; . /opt/yaw/backend/.env; set +a; fi; \
	if [ -f .env.prod ]; then set -a; . ./.env.prod; set +a; fi; \
	if [ -z "$${API_BASE_URL:-}" ]; then echo "API_BASE_URL kosong — isi API_BASE_URL di /opt/yaw/backend/.env atau .env.prod"; exit 1; fi; \
	flutter build web --release --dart-define=API_BASE_URL=$${API_BASE_URL}
	# Konfirmasi path docroot sebelum copy (default /var/www/yaw-web):
	sudo rm -rf /var/www/yaw-web && sudo cp -r build/web /var/www/yaw-web

deploy-restart: ## Restart backend + reload nginx (VPS)
	sudo systemctl restart yaw-backend && sudo systemctl reload nginx

deploy-logs: ## Follow log backend via journalctl (VPS)
	journalctl -u yaw-backend -f

deploy-verify: ## Curl health lokal + petunjuk login seed (VPS)
	curl -s http://localhost:3002/api/health | head -c 500; echo
	@echo "Login seed: admin@yaw.id / admin123 (POST /api/v1/auth/login, ganti setelah masuk)."
