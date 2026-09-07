# YAW — Futuristic Automotive Marketplace

> Flutter + REST API (Node.js + TypeScript + Express) + MariaDB. Desain dark futuristik untuk belajar full-stack.

## Quick start

```bash
flutter pub get
flutter run -d linux   # atau -d chrome / -d android
# login demo: admin@yaw.id / admin123  (admin)
# atau email apapun + password >=6  (user, mock offline)
```

Backend:

```bash
cd backend
npm install
cp .env.example .env   # isi DB_PASSWORD & JWT_SECRET
mysql -u root -p < ../database/migrations/001_init.sql
npm run dev            # http://localhost:3000  health: /api/health
```

Lihat `docs/YAW — Production Development Guide.md` untuk PRD lengkap.
