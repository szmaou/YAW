# AGENTS.md — YAW

YAW = Flutter (Riverpod + GoRouter) + Node.js/Express + MariaDB automotive marketplace. Two projects in one repo: `lib/` (Flutter) and `backend/` (TypeScript). No monorepo tool, no `opencode.json`, no `CLAUDE.md`, no CI workflows.

## Stack & Layout
- **Flutter** (Dart `^3.12.0`, Flutter ≥3.44 for go_router 18) — `go_router ^18.0.1`, `flutter_riverpod ^3.4.3` (+ `riverpod_annotation ^4.0.7` / `riverpod_generator ^4.0.9` / `riverpod_lint ^3.1.9`), `dio ^5.7.0`, `intl 0.20.2`, `flutter_secure_storage ^11.0.0`, `google_fonts ^8.2.1`, `cached_network_image ^4.0.0`, `shimmer ^4.0.0`, `freezed ^4.0.1`. No `custom_lint` (removed — conflicts with riverpod_lint 3.x). Assets: `assets/images/` `assets/icons/`.
- **Backend** — `backend/src/app.ts` is entrypoint (`tsx watch src/app.ts` dev, `tsc` build → `node dist/app.js`). Strict TS, target `ES2022`/`commonjs`, `outDir dist`. Express 5, helmet 8, dotenv 17, bcryptjs 3 (types bundled — no `@types/bcryptjs`), multer 2 (needs `@types/multer ^2.2.0`), zod 4, TS 7, `@types/node ^26`, `@types/express ^5`.
- **DB** — MariaDB 11.4, 8 tables (`users`, `vehicle_categories`, `vehicles`, `vehicle_images`, `favorites`, `orders`, `order_items`, `payments`) in `database/migrations/001_init.sql`. `users.id` and all PKs are `BIGINT UNSIGNED`.

## Setup — Order Matters
```bash
# 1) DB must exist before backend starts
docker compose up -d                    # creates yaw + yaw_user/yaw123 on 3306 (volume yaw_data)
# — or native MariaDB (needs one-time sudo):
sudo mariadb -u root -e "CREATE DATABASE IF NOT EXISTS yaw CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'yaw_user'@'%' IDENTIFIED BY 'yaw123'; CREATE USER IF NOT EXISTS 'yaw_user'@'localhost' IDENTIFIED BY 'yaw123'; GRANT ALL ON yaw.* TO 'yaw_user'@'%'; GRANT ALL ON yaw.* TO 'yaw_user'@'localhost'; FLUSH PRIVILEGES;"
mariadb -u yaw_user -p'yaw123' -h 127.0.0.1 -e "SHOW TABLES FROM yaw;"  # verify

# 2) Backend
cd backend && cp .env.example .env && npm install && npm run dev   # http://localhost:3002
# seeded automatically on first empty-DB start: admin@yaw.id/admin123 (admin), user@yaw.id/user123 (user) + 3 categories
npm run seed   # idempotent re-seed
npm run build && npm start  # production: tsc -> node dist/app.js

# 3) Flutter
flutter pub get && flutter run -d linux   # or -d chrome / android
# demo login even without DB: admin@yaw.id/admin123; any email + password>=6 -> mock user
```
`.env` is gitignored (`backend/.env`). `DB_PORT=3306` is canonical; `DB_SETUP.md` still mentions `3307` — ignore it. `tsx watch` does **not** watch `.env` — restart manually after env changes.

## Makefile — Canonical Shortcuts
Run `make help` for the full list. Prefer `make <target>` over raw bash — the Makefile is the source of truth for ports, paths, and order.
- `make setup` → `db-up` + `backend-install` + `app-install` (first run)
- `make db-up / db-down / db-verify / db-reset / db-logs` → MariaDB lifecycle (`docker compose` at repo root, `3306`)
- `make backend-dev / backend-build / backend-start / backend-seed / backend-typecheck / backend-health` → backend (`backend/` on `3002`)
- `make app-run (= app-run-linux) / app-run-chrome / app-analyze / app-analyze-focused / app-test / fix-cmake` → Flutter
- `make verify` → `backend-typecheck` + `app-analyze` (both must be 0 errors)

## Verification (Exact Commands)
```bash
make verify                               # backend tsc + dart analyze — both must be 0 errors (~70 infos is clean)
make backend-typecheck                    # same as: cd backend && ./node_modules/.bin/tsc --noEmit
make app-analyze                          # same as: /opt/flutter/bin/cache/dart-sdk/bin/dart analyze (direct SDK; `flutter analyze` masks output)
make app-analyze-focused                  # focused: lib/app/router.dart lib/main.dart
make app-test                             # flutter test (single widget_test)
make backend-health                       # curl /api/health + POST /api/v1/auth/login
# Raw equivalents if not using make:
./node_modules/.bin/tsc --noEmit          # from backend/
# Frontend — ~70 infos is clean (unnecessary_underscores, deprecated value, use_build_context). 0 errors = pass
/opt/flutter/bin/cache/dart-sdk/bin/dart analyze   # use direct SDK path; `flutter analyze` wrapper masks output with git status
/opt/flutter/bin/cache/dart-sdk/bin/dart analyze lib/app/router.dart lib/main.dart   # focused check
flutter test   # single widget_test only
curl -s http://localhost:3002/api/health                          # 200 {"success":true}
curl -s -X POST http://localhost:3002/api/v1/auth/login -H 'Content-Type: application/json' -d '{"email":"admin@yaw.id","password":"admin123"}'  # 200 + JWT; GET on same path is 404 by design
```

## Architecture — Not Obvious
- **Router** `lib/app/router.dart`: `Provider<GoRouter>` with `ValueNotifier<int>(0)` as `refreshListenable` + `ref.listen(authProvider, (_,__)=>refresh.value++)` + `ref.read(authProvider)` in `redirect`. Riverpod 3 removed `Ref` type params — `ref.listen<AuthState>` no longer compiles. Do **not** hold `Ref` in a `ChangeNotifier` and do **not** `watch(authProvider)` inside the provider — that recreates `GoRouter` and triggers `Navigator !keyReservation.contains(key)` assertion.
- **ShellRoute**: all routes (user + `/admin/**`) are **inside** one `ShellRoute` (wrapping `AppShell`) so the sidebar stays visible on admin pages. `AppShell` is a `ConsumerWidget` watching `authProvider.isAdmin` — Admin tab appears before Profile only for admins, and `/admin/*` sub-routes highlight it. History: admin used to live outside the ShellRoute, where `context.push` across the boundary duplicated the Shell page key (`ValueKey(route.hashCode)`) and crashed — fix was `context.go`. Keep `context.go` for admin↔user navigation anyway.
- **Admin CRUD** lives in `lib/features/admin/{vehicles,users,categories,orders}/` + `lib/features/admin/shared/admin_app_bar.dart`. Routes `/admin/dashboard`, `/admin/vehicles`, `/admin/vehicles/new`, `/admin/vehicles/:id/edit`, `/admin/users`, `/admin/categories`, `/admin/orders` are inside the ShellRoute. Non-admins hitting `/admin*` are redirected to `/home`.
- **Riverpod 3**: `StateNotifierProvider` lives in `package:flutter_riverpod/legacy.dart` — providers using it (`auth`, `vehicleList`, `favorites`) must import legacy. `AsyncValue.valueOrNull` is renamed to `.value`. Guard async `ref` use with `if (!mounted) return` after `await` (`checkAuth`, `load`).
- **Backend auth**: `auth()` checks `Bearer <JWT>` via `verify()`; `adminOnly` checks `role==='admin'`. `JWT_SECRET=yaw123` in `.env` is dev-only. Frontend `ApiClient` attaches token via `SecureStorage` interceptor; `AuthRepository` falls back to mock tokens (`mock_admin_token`/`mock_user_token`) on `DioException.connectionError` → those tokens fail JWT verify against a real DB. After DB becomes available, users must **logout + login** to replace the mock token with a real `eyJ...` JWT.
- **Orders transaction**: `POST /orders` uses `pool.getConnection() → beginTransaction → SELECT ... FOR UPDATE → inserts → UPDATE stock → commit/rollback → release`. No stock check outside the transaction.

## Hard-Earned Gotchas
- **BigInt**: MariaDB `BIGINT UNSIGNED` → JS `BigInt`. `backend/src/app.ts` sets `app.set('json replacer', (_,v)=>typeof v==='bigint'?String(v):v)` — removing it crashes every `res.json({id: ...})` with `TypeError: Do not know how to serialize a BigInt`.
- **Locale**: `lib/main.dart` must `await initializeDateFormatting('id_ID', null)` before `runApp`. `lib/core/utils/formatters.dart` is lazy (`_idrCache ??=`) and `date()`/`dateTime()` try/catch fallback to default locale — without both, `OrdersPage`/`AdminDashboard` throw `LocaleDataException`.
- **DB fail-fast**: `backend/src/config/initDb.ts` races `pool.getConnection()` in 3s; if unreachable it logs `[initDb] skip migrations - pool unreachable` and returns early. `start()` still calls `app.listen` so `/api/health` stays 200 while DB routes return `503` with Indonesian hint. Don't loop per-statement `getConnection` on unreachable pool — it hangs startup for minutes.
- **`db.ts`**: forces `localhost → 127.0.0.1` to avoid unix socket; `pool.on('error')` is `(pool as any).on('error')` because mariadb types only declare `release`.
- **`backend/src/config/initDb.ts` fallback**: tries `yaw_user` first, then `root/root123`, `root/''`, `root/$MARIADB_ROOT_PASSWORD` via `mariadb.createConnection` (no DB). On Arch, `root` uses `unix_socket` so those fallbacks fail — use `sudo mariadb` or Docker instead.
- **`errorHandler.ts` messages** still reference `3310` — actually `3306` after the fix.
- **Rebuild caches**: project was moved from `PB/YAW` → `YAW`; absolute CMake/dart-tool caches cause `CMakeCache.txt` mismatch. After any path move: `rm -rf build/ .dart_tool/ && flutter clean && flutter pub get`. `flutter run` router changes need full restart (`R`), not hot reload.

## Conventions
- Theme: `lib/app/theme.dart` dark `YawColors` (`#0B0F14` bg, `#00E5FF` primary). Use `InkWell + Container` (not `ListTile`) with `YawColors.surface/surface2/border` — `ListTile` inside colored `Container` hides ink splash.
- API base: `http://localhost:3002/api/v1` (`10.0.2.2:3002` on Android emulator) in `lib/core/constants/app_constants.dart`.
- `.gitignore` excludes `.env`, `backend/.env`, `.opencode/`, `node_modules/`, `uploads/`. Commit `backend/.env.example` instead.
- `docker-compose.yml` at repo root is the single source of truth for local MariaDB.
