# YAW Backend — Bring MariaDB Up

The API starts even when the DB is down (pool failures are non-fatal at boot), but
no DB-dependent route will work until MariaDB is running and reachable.

## Current state (diagnosed)

- `.env` expects MariaDB at `127.0.0.1:3307`, database `yaw`, user `yaw_user` / `yaw123`.
- No listener on `3307` (or `3306`). MariaDB daemon is **not running**.
- Docker daemon is **not running** (no docker socket) and there is **no `docker-compose.yml`**
  at the repo root or in `backend/`.
- MariaDB server binary (`mariadbd`) **is installed** on the host, but the default port is `3306`.

## Root cause

The backend cannot retrieve a pooled connection because **nothing is listening** on the
configured `DB_PORT` (3307). This is a "server unreachable" failure (active=0, idle=0),
**not** pool exhaustion or a config bug.

## How to fix (pick one)

### Option A — Start the locally-installed MariaDB (no Docker)

```bash
# 1. Start the service (sudo will prompt for your password)
sudo systemctl start mariadb      # or: sudo service mariadb start

# 2. (first run only) initialize if the data dir is empty
# sudo mariadb-install-db --user=mysql --datadir=/var/lib/mysql

# 3. Harden / set a root password (optional but recommended)
sudo mysql_secure_installation

# 4. Create the yaw database + user (run as root)
sudo mariadb -u root <<'SQL'
CREATE DATABASE IF NOT EXISTS yaw CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'yaw_user'@'%' IDENTIFIED BY 'yaw123';
GRANT ALL PRIVILEGES ON yaw.* TO 'yaw_user'@'%';
FLUSH PRIVILEGES;
SQL
```

#### Port note — .env uses 3307, MariaDB defaults to 3306

If you start MariaDB with the default config, it listens on **3306**, but `.env` (and `.env.example`)
point at **3307**. Choose ONE:

- **Easiest:** set `DB_PORT=3306` in `backend/.env` (then `initDb` will connect correctly).
- **Or** make MariaDB listen on 3307 by adding to `/etc/my.cnf.d/server.cnf` under `[mysqld]`:
  ```
  [mysqld]
  port=3307
  ```
  then `sudo systemctl restart mariadb`.

### Option B — Run MariaDB in Docker (recommended for portability)

From the repo root (`/home/san/Documents/YAW`):

```bash
# Start Docker daemon first (required before compose):
#   macOS: open Docker Desktop
#   Linux: sudo systemctl start docker
#           (sudo will prompt for your password)

docker run -d \
  --name yaw-mariadb \
  -e MARIADB_ROOT_PASSWORD=root123 \
  -e MARIADB_DATABASE=yaw \
  -e MARIADB_USER=yaw_user \
  -e MARIADB_PASSWORD=yaw123 \
  -p 3307:3306 \
  mariadb:11.4

# Initialise/wait until 'docker logs yaw-mariadb' shows "ready for connections", then:
cd /home/san/Documents/YAW/backend
npm run dev
```

> The `-p 3307:3306` mapping exposes MariaDB on the host's port 3307, matching `.env`.

## Verify

```bash
# Confirm something is listening on 3307
ss -tlnp | grep 3307          # should print a mariadbd listener

# Confirm auth works
mariadb -h 127.0.0.1 -P 3307 -u yaw_user -pyaw123 yaw -e "SELECT 1 AS ok;"
```

## Restart the API after the DB is up

```bash
cd /home/san/Documents/YAW/backend
npm run dev
# Expect:
# [initDb] ensuring database — target: 127.0.0.1:3307/yaw as yaw_user
# [YAW] Database ready
# [YAW] API listening on http://localhost:3002
# [YAW] Health: http://localhost:3002/api/health
```
