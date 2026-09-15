# YAW — Flutter + Express + MariaDB (Docker deploy + testing)
# `make help` lists all targets. Fokus: deploy (docker) + testing.
# Dev lokal tetap butuh: docker compose (DB), npm (backend), flutter (app).

SHELL := /bin/bash
.DEFAULT_GOAL := help

BACKEND_DIR := backend

# ── help ──────────────────────────────────────────────────────────
.PHONY: help
help: ## Show this help
	@echo "YAW — make targets (deploy + testing)"
	@echo ""
	@grep -E '^[a-zA-Z0-9_/-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Deploy:   cp .env.prod.example .env.prod (isi secret) && make deploy-up"
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

# ── deploy (production: Docker-only, docker-compose.prod.yml + .env.prod) ──
.PHONY: deploy-build deploy-up deploy-down deploy-logs deploy-verify deploy-web-rebuild

deploy-build: ## Build image prod (cek API_BASE_URL di .env.prod)
	@if [ -f .env.prod ]; then set -a; . ./.env.prod; set +a; fi; \
	if [ -z "$${API_BASE_URL:-}" ]; then echo "API_BASE_URL kosong — isi .env.prod (cp .env.prod.example .env.prod)"; exit 1; fi; \
	docker compose -f docker-compose.prod.yml --env-file .env.prod build --pull

deploy-up: ## Up stack prod (-d + ps)
	docker compose -f docker-compose.prod.yml --env-file .env.prod build --pull
	docker compose -f docker-compose.prod.yml --env-file .env.prod up -d
	docker compose -f docker-compose.prod.yml --env-file .env.prod ps

deploy-down: ## Down stack prod (volume dipertahankan)
	docker compose -f docker-compose.prod.yml --env-file .env.prod down

deploy-logs: ## Follow log backend + web prod
	docker compose -f docker-compose.prod.yml --env-file .env.prod logs -f yaw-backend yaw-web

deploy-verify: ## Curl web->api prod + petunjuk login seed
	@if [ -f .env.prod ]; then set -a; . ./.env.prod; set +a; fi; \
	curl -s http://localhost:$${WEB_PORT:-80}/api/health | head -c 500; echo
	@echo "Login seed: admin@yaw.id / admin123 (POST /api/v1/auth/login, ganti setelah masuk)."

deploy-web-rebuild: ## Rebuild yaw-web saja (mis. ganti API_BASE_URL)
	docker compose -f docker-compose.prod.yml --env-file .env.prod build --pull yaw-web
	docker compose -f docker-compose.prod.yml --env-file .env.prod up -d yaw-web
	docker compose -f docker-compose.prod.yml --env-file .env.prod ps
