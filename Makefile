# YAW — Flutter + Express + MariaDB
# `make help` lists all targets. Use `make <target>` (not raw bash) for canonical flows.

SHELL := /bin/bash
.DEFAULT_GOAL := help

BACKEND_DIR := backend
DC          := docker compose

# ── help ──────────────────────────────────────────────────────────
.PHONY: help
help: ## Show this help
	@echo "YAW — make targets"
	@echo ""
	@grep -E '^[a-zA-Z0-9_/-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Typical first run:  make setup  &&  make backend-dev   (in another shell: make app-run)"

# ── setup ─────────────────────────────────────────────────────────
.PHONY: setup
setup: db-up backend-install app-install ## Full first-time setup (DB + backend deps + flutter deps)
	@echo "Setup done. Next: make backend-dev  (and in another shell: make app-run)"

# ── DB (docker-compose.yml at repo root, port 3306) ──────────────
.PHONY: db-up db-down db-restart db-logs db-ps db-shell db-verify db-reset

db-up: ## Start MariaDB (yaw + yaw_user/yaw123 on 3306, volume yaw_data)
	$(DC) up -d
	@echo "Waiting for MariaDB healthcheck..."
	@for i in $$(seq 1 30); do $(DC) ps 2>/dev/null | grep -q "healthy" && break; sleep 1; done; true
	@$(DC) ps

db-down: ## Stop MariaDB (keeps volume)
	$(DC) down

db-restart: db-down db-up ## Restart MariaDB

db-logs: ## Tail MariaDB logs
	$(DC) logs -f yaw-db

db-ps: ## Show compose status
	$(DC) ps

db-shell: ## Open mariadb shell as yaw_user
	mariadb -u yaw_user -p'yaw123' -h 127.0.0.1 -P 3306 yaw

db-verify: ## Verify DB reachable + tables exist
	mariadb -u yaw_user -p'yaw123' -h 127.0.0.1 -P 3306 -e "SHOW TABLES FROM yaw;"

db-reset: ## DESTROY volume + recreate DB from scratch (requires confirmation)
	@echo "This will DELETE yaw_data volume. Ctrl+C to abort, Enter to continue..."; read _
	$(DC) down -v
	$(DC) up -d
	@echo "DB reset — backend will re-run migrations + seed on next start."

# ── Backend (backend/src/app.ts, port 3002) ──────────────────────
.PHONY: backend-install backend-dev backend-build backend-start backend-seed backend-typecheck backend-health backend-logs

backend-install: ## Install backend deps (npm install)
	cd $(BACKEND_DIR) && npm install

backend-dev: ## Run backend in watch mode (ts-node-dev, needs DB up)
	cd $(BACKEND_DIR) && npm run dev

backend-build: ## TypeScript build -> dist/
	cd $(BACKEND_DIR) && npm run build

backend-start: ## Run built backend (node dist/app.js)
	cd $(BACKEND_DIR) && npm start

backend-seed: ## Idempotent re-seed admin@yaw.id/admin123 + categories (needs DB up)
	cd $(BACKEND_DIR) && npm run seed

backend-typecheck: ## Typecheck backend (must be EXIT 0)
	cd $(BACKEND_DIR) && ./node_modules/.bin/tsc --noEmit

backend-health: ## Curl health + login (needs backend running)
	@curl -s http://localhost:3002/api/health | head -c 500; echo
	@curl -s -X POST http://localhost:3002/api/v1/auth/login -H 'Content-Type: application/json' -d '{"email":"admin@yaw.id","password":"admin123"}' | head -c 700; echo

# ── Frontend (Flutter) ────────────────────────────────────────────
.PHONY: app-install app-run app-run-linux app-run-chrome app-analyze app-analyze-focused app-test app-clean fix-cmake

app-install: ## Fetch Flutter deps
	flutter pub get

app-run: app-run-linux ## Alias for app-run-linux

app-run-linux: ## Run Flutter on Linux desktop
	flutter run -d linux

app-run-chrome: ## Run Flutter on Chrome
	flutter run -d chrome

app-analyze: ## Dart analyze (use direct SDK; ~70 infos is clean, 0 errors = pass)
	/opt/flutter/bin/cache/dart-sdk/bin/dart analyze

app-analyze-focused: ## Analyze only hot files (router + main)
	/opt/flutter/bin/cache/dart-sdk/bin/dart analyze lib/app/router.dart lib/main.dart

app-test: ## Run Flutter tests
	flutter test

app-clean: ## Clean Flutter build artifacts
	flutter clean

fix-cmake: ## Fix CMakeCache path mismatch after moving repo (PB/YAW -> YAW)
	rm -rf build/ .dart_tool/
	flutter clean && flutter pub get

# ── combined verification ─────────────────────────────────────────
.PHONY: verify
verify: backend-typecheck app-analyze ## Run backend typecheck + dart analyze (both must be 0 errors)
	@echo "verify done — backend tsc + dart analyze passed (infos are ok, errors must be 0)."

# ── full clean ────────────────────────────────────────────────────
.PHONY: clean
clean: ## Remove all build artifacts (Flutter + backend dist)
	rm -rf build/ .dart_tool/ .flutter-plugins-dependencies
	cd $(BACKEND_DIR) && rm -rf dist/ node_modules/.cache 2>/dev/null; true
	@echo "clean done. Run: make app-install && make backend-install"
