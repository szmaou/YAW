import mariadb from 'mariadb';
import fs from 'fs';
import path from 'path';

const candidates = [
  { host: '127.0.0.1', port: 3307, user: 'root', password: 'root123', label: 'flutter_auth_db (3307) root' },
  { host: '127.0.0.1', port: 3306, user: 'root', password: 'root123', label: 'host 3306 root/root123' },
  { host: '127.0.0.1', port: 3306, user: 'root', password: '', label: 'host 3306 root/(empty)' },
];

async function tryConnect(c) {
  console.log(`\n[TRY] ${c.label} -> ${c.host}:${c.port} as ${c.user}`);
  let conn;
  try {
    conn = await mariadb.createConnection({ host: c.host, port: c.port, user: c.user, password: c.password, connectTimeout: 5000 });
    console.log(`[OK] connected ${c.label}`);
    // create yaw db + user
    await conn.query(`CREATE DATABASE IF NOT EXISTS yaw CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
    console.log('[OK] CREATE DATABASE yaw');
    await conn.query(`CREATE USER IF NOT EXISTS 'yaw_user'@'%' IDENTIFIED BY 'yaw123'`);
    await conn.query(`GRANT ALL PRIVILEGES ON yaw.* TO 'yaw_user'@'%'`);
    await conn.query(`FLUSH PRIVILEGES`);
    console.log('[OK] CREATE USER yaw_user + GRANT');

    // run migrations from database/migrations/001_init.sql but skip CREATE DATABASE/USE
    const migPath = path.resolve('database/migrations/001_init.sql');
    let sql = fs.readFileSync(migPath, 'utf8');
    // remove CREATE DATABASE and USE lines to avoid re-creating
    sql = sql.replace(/CREATE DATABASE.*;/gi, '-- skip').replace(/USE yaw;/gi, '-- skip USE');
    // split by ; and execute
    // mariadb driver can handle multiple statements if allow, but we do simple split
    const statements = sql.split(';').map(s => s.trim()).filter(s => s && !s.startsWith('-- skip') && s.length > 5);
    // Use yaw database for migrations
    await conn.query('USE yaw');
    for (const stmt of statements) {
      try {
        await conn.query(stmt);
      } catch (e) {
        // ignore "already exists" errors
        if (!String(e.message).includes('already exists') && !String(e.message).includes('Duplicate')) {
          console.error('[MIG ERR]', e.message, '\nSQL:', stmt.slice(0, 200));
        }
      }
    }
    console.log('[OK] Migrations applied');

    const rows = await conn.query('SHOW TABLES FROM yaw');
    console.log('[TABLES yaw]', rows.map(r => Object.values(r)[0]));

    // verify yaw_user can connect
    await conn.end();
    const testConn = await mariadb.createConnection({ host: c.host, port: c.port, user: 'yaw_user', password: 'yaw123', database: 'yaw', connectTimeout: 5000 });
    const r = await testConn.query('SELECT 1 as ok');
    console.log('[OK] yaw_user can connect:', r);
    await testConn.end();

    console.log(`\n[SUCCESS] YAW DB ready on ${c.host}:${c.port}. Update backend/.env DB_PORT=${c.port} if needed.`);
    return true;
  } catch (e) {
    console.error(`[FAIL] ${c.label}:`, e.message);
    if (conn) try { await conn.end(); } catch {}
    return false;
  }
}

let ok = false;
for (const c of candidates) {
  if (await tryConnect(c)) { ok = true; break; }
}
if (!ok) {
  console.error('\n[FAILED] Could not setup yaw DB on any candidate. Check: docker ps, ss -tlnp, and MARIADB_ROOT_PASSWORD.');
  process.exit(1);
}
