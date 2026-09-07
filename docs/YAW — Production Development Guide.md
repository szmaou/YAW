# YAW — Production Development Guide

> **YAW** adalah aplikasi penjualan kendaraan berbasis Flutter dengan desain modern dan futuristik.  
> Proyek ini dibuat **untuk belajar** membangun aplikasi full-stack yang memiliki sisi **User** dan **Admin**, menggunakan **Flutter** sebagai frontend dan **MariaDB** sebagai database.

---

# 1. Project Overview

## 1.1 Nama Aplikasi

**YAW**

YAW merupakan platform penjualan kendaraan yang memungkinkan pengguna untuk:

- Melihat daftar kendaraan
- Melihat detail kendaraan
- Mencari dan memfilter kendaraan
- Melihat spesifikasi kendaraan
- Menyimpan kendaraan favorit
- Melakukan pemesanan
- Melihat riwayat pemesanan
- Mengelola profil

Sedangkan Admin dapat:

- Mengelola kendaraan
- Mengelola kategori kendaraan
- Mengelola pengguna
- Mengelola pesanan
- Mengelola stok kendaraan
- Melihat dashboard penjualan
- Mengelola konten kendaraan

---

# 2. Tujuan Project

Project ini dibuat sebagai **project pembelajaran full-stack development**.

Target pembelajaran:

1. Flutter multi-platform development
2. Clean Architecture
3. REST API
4. Authentication & Authorization
5. Database relational
6. MariaDB
7. CRUD
8. File/image upload
9. State management
10. API integration
11. Admin dashboard
12. Responsive UI
13. Error handling
14. Security dasar
15. Deployment

---

# 3. Platform

Flutter digunakan untuk seluruh platform utama:

- Android
- iOS
- Windows
- Linux
- macOS
- Web

Target utama pengembangan:

```text
Flutter
├── Android
├── iOS
├── Windows
├── Linux
├── macOS
└── Web
```

UI harus dibuat **responsive**, terutama untuk:

- Mobile
- Tablet
- Desktop
- Web

---

# 4. Architecture

Project menggunakan arsitektur:

```text
Flutter Application
        │
        │ HTTP / HTTPS
        ▼
    REST API
        │
        ▼
    MariaDB
```

Flutter **tidak boleh langsung terhubung ke MariaDB**.

Flutter harus berkomunikasi melalui backend API.

```text
Flutter
   │
   │ REST API
   ▼
Backend Server
   │
   │ SQL
   ▼
MariaDB
```

---

# 5. Recommended Technology Stack

## Frontend

```text
Flutter
Dart
```

Recommended libraries:

```text
flutter_riverpod
go_router
dio
freezed
json_serializable
cached_network_image
flutter_secure_storage
intl
image_picker
```

Library dapat berubah selama proses pembelajaran apabila terdapat alternatif yang lebih sesuai.

---

# 6. Backend

Backend digunakan sebagai penghubung Flutter dengan MariaDB.

Recommended:

```text
Node.js
TypeScript
Express / Fastify
MariaDB
JWT
```

Alternatif backend yang diperbolehkan:

```text
Laravel
Node.js
Go
Java Spring Boot
```

Namun untuk project pembelajaran ini, default:

```text
Node.js + TypeScript
```

---

# 7. Database

Database:

```text
MariaDB
```

Database name:

```text
yaw
```

Contoh:

```text
MariaDB
└── yaw
    ├── users
    ├── vehicles
    ├── vehicle_categories
    ├── vehicle_images
    ├── favorites
    ├── orders
    ├── order_items
    └── payments
```

---

# 8. User Roles

Terdapat minimal 2 role:

```text
USER
ADMIN
```

## USER

User dapat:

- Register
- Login
- Logout
- Melihat kendaraan
- Mencari kendaraan
- Filter kendaraan
- Melihat detail kendaraan
- Favorite kendaraan
- Membuat pesanan
- Melihat pesanan
- Melihat profil
- Mengubah profil

## ADMIN

Admin dapat:

- Login
- Melihat dashboard
- CRUD kendaraan
- CRUD kategori
- Mengelola user
- Mengelola pesanan
- Mengubah status pesanan
- Mengelola stok
- Melihat statistik

---

# 9. Authentication

Authentication menggunakan:

```text
JWT
```

Flow:

```text
User
 │
 │ Login
 ▼
API
 │
 │ Validate username/password
 ▼
Database
 │
 │ Valid
 ▼
JWT Token
 │
 ▼
Flutter
```

Token disimpan menggunakan secure storage.

Jangan menyimpan token authentication menggunakan:

```text
SharedPreferences
```

untuk production.

Gunakan:

```text
flutter_secure_storage
```

---

# 10. Database Design

## users

```sql
users
-----------------------
id
name
email
password
phone
role
avatar
created_at
updated_at
```

Role:

```text
user
admin
```

---

## vehicle_categories

```sql
vehicle_categories
-----------------------
id
name
slug
description
created_at
updated_at
```

Contoh:

```text
Car
Motorcycle
Electric Vehicle
Commercial
SUV
Sedan
```

---

## vehicles

```sql
vehicles
-----------------------
id
category_id
name
slug
brand
model
year
price
stock
description
engine
transmission
fuel_type
color
is_available
created_at
updated_at
```

---

## vehicle_images

```sql
vehicle_images
-----------------------
id
vehicle_id
image_url
is_primary
created_at
```

Satu kendaraan dapat memiliki banyak gambar.

```text
Vehicle
   │
   ├── image 1
   ├── image 2
   ├── image 3
   └── image 4
```

---

## favorites

```sql
favorites
-----------------------
id
user_id
vehicle_id
created_at
```

Relasi:

```text
User
 │
 └── Favorites
       │
       ├── Vehicle
       ├── Vehicle
       └── Vehicle
```

---

## orders

```sql
orders
-----------------------
id
user_id
order_number
total_amount
status
created_at
updated_at
```

Status:

```text
pending
confirmed
processing
completed
cancelled
```

---

## order_items

```sql
order_items
-----------------------
id
order_id
vehicle_id
quantity
price
subtotal
```

---

## payments

```sql
payments
-----------------------
id
order_id
payment_method
payment_status
transaction_id
paid_at
created_at
```

Payment status:

```text
pending
paid
failed
refunded
```

---

# 11. Database Relationship

```text
users
  │
  ├───────────────┐
  │               │
  ▼               ▼
favorites       orders
  │               │
  ▼               ▼
vehicles      order_items
  │               │
  ▼               ▼
categories     vehicles
```

---

# 12. Flutter Project Structure

Gunakan struktur:

```text
yaw/
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── lib/
│   │
│   ├── main.dart
│   │
│   ├── app/
│   │   ├── app.dart
│   │   ├── router.dart
│   │   └── theme.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── network/
│   │   ├── storage/
│   │   ├── utils/
│   │   └── widgets/
│   │
│   ├── features/
│   │
│   │   ├── auth/
│   │   ├── home/
│   │   ├── vehicles/
│   │   ├── favorites/
│   │   ├── orders/
│   │   ├── profile/
│   │   │
│   │   └── admin/
│   │       ├── dashboard/
│   │       ├── vehicles/
│   │       ├── categories/
│   │       ├── users/
│   │       └── orders/
│   │
│   └── shared/
│       ├── models/
│       └── widgets/
│
├── test/
│
├── pubspec.yaml
└── README.md
```

---

# 13. Feature Architecture

Setiap feature dibuat terpisah.

Contoh:

```text
features/
└── vehicles/
    │
    ├── data/
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    │
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    │
    └── presentation/
        ├── providers/
        ├── pages/
        └── widgets/
```

Tujuan:

```text
Presentation
      │
      ▼
   Domain
      │
      ▼
     Data
```

UI tidak boleh langsung melakukan query database.

---

# 14. Main Application Pages

## Public

```text
Splash
Login
Register
Home
Vehicle List
Vehicle Detail
Search
Category
```

## User

```text
Home
Favorites
Orders
Order Detail
Profile
Settings
```

## Admin

```text
Admin Login
Dashboard
Vehicle Management
Add Vehicle
Edit Vehicle
Category Management
User Management
Order Management
Order Detail
Settings
```

---

# 15. User Navigation

Mobile:

```text
Home
Vehicles
Favorites
Orders
Profile
```

Desktop:

```text
┌───────────────────────────────────────────┐
│ YAW                         Search  Profile│
├───────────┬───────────────────────────────┤
│ Home      │                               │
│ Vehicles  │         CONTENT               │
│ Favorites │                               │
│ Orders    │                               │
│ Profile   │                               │
└───────────┴───────────────────────────────┘
```

---

# 16. Admin Navigation

```text
Dashboard
Vehicles
Categories
Orders
Users
Reports
Settings
Logout
```

Dashboard:

```text
┌────────────────────────────────────────────┐
│ Dashboard                                  │
├────────────┬────────────┬────────────┬─────┤
│ Vehicles   │ Orders     │ Users      │ ... │
├────────────┴────────────┴────────────┴─────┤
│                                            │
│              SALES CHART                   │
│                                            │
├────────────────────────────────────────────┤
│ Recent Orders                              │
│                                            │
└────────────────────────────────────────────┘
```

---

# 17. UI / UX Design

Tema utama:

# Futuristic Automotive

Desain harus terasa seperti aplikasi perusahaan kendaraan modern.

Inspirasi visual:

```text
Modern
Futuristic
Clean
Premium
Minimal
Automotive
Technology
```

Hindari:

```text
UI terlalu ramai
Gradient berlebihan
Terlalu banyak warna
Card terlalu besar
Animasi berlebihan
```

---

# 18. Color System

Gunakan warna dasar:

```text
Background:
#0B0F14

Surface:
#121820

Primary:
#00E5FF

Secondary:
#7C4DFF

Text:
#FFFFFF

Muted:
#8B95A5

Success:
#00E676

Warning:
#FFB300

Error:
#FF5252
```

Warna dapat disesuaikan ketika proses desain berlangsung.

---

# 19. Typography

Gunakan font modern seperti:

```text
Inter
```

atau:

```text
Space Grotesk
```

Hierarki:

```text
Display
Heading
Title
Body
Caption
```

Contoh:

```text
YAW

Explore the future
of mobility.
```

---

# 20. Vehicle Card

Card kendaraan harus menampilkan:

```text
┌────────────────────────────┐
│                            │
│        VEHICLE IMAGE       │
│                            │
├────────────────────────────┤
│ Toyota                     │
│ GR Supra                   │
│                            │
│ Rp 1.200.000.000           │
│                            │
│ 2025 • Automatic • Petrol  │
└────────────────────────────┘
```

Gunakan:

- Rounded corners
- Image besar
- Typography minimal
- Favorite button
- Price yang jelas
- Status stok

---

# 21. Vehicle Detail

Halaman detail harus memiliki:

```text
Image Gallery

Brand
Vehicle Name
Price

Specifications

Engine
Transmission
Fuel
Year
Color

Description

Stock

[ Buy / Order Now ]
```

Desktop:

```text
┌───────────────────┬──────────────────────┐
│                   │ Toyota GR Supra      │
│                   │                      │
│ VEHICLE IMAGE     │ Rp 1.200.000.000     │
│                   │                      │
│                   │ Specifications       │
│                   │                      │
│                   │ [ Order Now ]        │
└───────────────────┴──────────────────────┘
```

---

# 22. Home Page

Home harus memiliki:

```text
Hero Section
Featured Vehicles
Popular Categories
Latest Vehicles
Why Choose YAW
Call To Action
Footer
```

Hero:

```text
THE FUTURE
OF MOBILITY

Discover vehicles
built for tomorrow.

[ Explore Vehicles ]
```

Visual:

```text
Dark background
Large vehicle image
Subtle futuristic lighting
Minimal typography
```

---

# 23. Search & Filter

User dapat mencari berdasarkan:

```text
Brand
Model
Category
Price
Year
Fuel
Transmission
```

Contoh:

```text
Search vehicle...

Filters:

Category
Brand
Min Price
Max Price
Year
Fuel Type
Transmission
```

---

# 24. Order Flow

Flow:

```text
Vehicle Detail
      │
      ▼
Order Now
      │
      ▼
Order Confirmation
      │
      ▼
Payment
      │
      ▼
Order Created
      │
      ▼
Pending
      │
      ▼
Admin Confirmation
      │
      ▼
Processing
      │
      ▼
Completed
```

---

# 25. API Design

Base URL:

```text
/api/v1
```

Authentication:

```text
POST /auth/register
POST /auth/login
POST /auth/logout
GET  /auth/me
```

Vehicles:

```text
GET    /vehicles
GET    /vehicles/:id
POST   /vehicles
PUT    /vehicles/:id
DELETE /vehicles/:id
```

Categories:

```text
GET    /categories
POST   /categories
PUT    /categories/:id
DELETE /categories/:id
```

Favorites:

```text
GET    /favorites
POST   /favorites
DELETE /favorites/:vehicleId
```

Orders:

```text
GET  /orders
GET  /orders/:id
POST /orders
PUT  /orders/:id/status
```

Users:

```text
GET /users
GET /users/:id
PUT /users/:id
DELETE /users/:id
```

Admin dashboard:

```text
GET /admin/dashboard
GET /admin/statistics
```

---

# 26. API Response Format

Gunakan response yang konsisten.

Success:

```json
{
  "success": true,
  "message": "Vehicles retrieved successfully",
  "data": []
}
```

Error:

```json
{
  "success": false,
  "message": "Vehicle not found",
  "errors": []
}
```

---

# 27. Pagination

Endpoint list harus menggunakan pagination.

Contoh:

```text
GET /vehicles?page=1&limit=20
```

Response:

```json
{
  "success": true,
  "data": [],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 120,
    "totalPages": 6
  }
}
```

---

# 28. Image Management

Gambar kendaraan tidak disimpan langsung sebagai binary di database.

Database hanya menyimpan:

```text
image_url
```

Contoh:

```text
/uploads/vehicles/supra-01.webp
```

Storage dapat menggunakan:

```text
Local Storage
```

untuk development.

Untuk production dapat menggunakan:

```text
S3-compatible storage
```

---

# 29. Security

Minimal security:

- Password harus di-hash
- Jangan menyimpan password plain text
- JWT authentication
- Role-based authorization
- HTTPS
- Input validation
- SQL injection protection
- Rate limiting
- CORS configuration
- Secure HTTP headers
- File upload validation
- Maximum file size
- Validasi MIME type

Jangan pernah:

```text
password = "123456"
```

disimpan langsung di database.

---

# 30. Environment Variables

Jangan hard-code credential.

Backend:

```env
APP_PORT=3000

DB_HOST=localhost
DB_PORT=3306
DB_NAME=yaw
DB_USER=yaw_user
DB_PASSWORD=your_password

JWT_SECRET=your_secret

UPLOAD_PATH=./uploads
```

Jangan commit:

```text
.env
```

ke Git.

Gunakan:

```text
.env.example
```

sebagai template.

---

# 31. Git Structure

Repository:

```text
yaw/
├── frontend/
├── backend/
├── database/
├── docs/
└── README.md
```

Branch:

```text
main
develop
feature/*
bugfix/*
```

Contoh:

```text
feature/authentication
feature/vehicle-management
feature/admin-dashboard
bugfix/login-error
```

---

# 32. Commit Convention

Gunakan Conventional Commits.

Contoh:

```text
feat: add vehicle listing
feat: add authentication
fix: fix login validation
refactor: improve vehicle repository
docs: update production guide
style: update vehicle card UI
test: add auth tests
chore: update dependencies
```

---

# 33. Development Environment

Recommended:

```text
Flutter SDK
Dart SDK
Node.js
npm
MariaDB
Git
VS Code / Android Studio
```

Optional:

```text
Docker
Postman
DBeaver
Figma
```

---

# 34. Local Development

## Start MariaDB

Pastikan MariaDB aktif.

Database:

```text
yaw
```

Kemudian jalankan backend:

```bash
cd backend
npm install
npm run dev
```

Flutter:

```bash
cd frontend
flutter pub get
flutter run
```

---

# 35. Development Order

Jangan membuat semuanya sekaligus.

Ikuti tahapan:

## Phase 1 — Setup

- [ ] Setup repository
- [ ] Setup Flutter
- [ ] Setup backend
- [ ] Setup MariaDB
- [ ] Setup Git
- [ ] Setup environment variables

---

## Phase 2 — Database

- [ ] Create database
- [ ] Create users
- [ ] Create categories
- [ ] Create vehicles
- [ ] Create vehicle_images
- [ ] Create favorites
- [ ] Create orders
- [ ] Create order_items
- [ ] Create payments
- [ ] Setup relations
- [ ] Create seed data

---

## Phase 3 — Backend

- [ ] Setup REST API
- [ ] Authentication
- [ ] JWT
- [ ] User authorization
- [ ] Vehicle CRUD
- [ ] Category CRUD
- [ ] Favorite API
- [ ] Order API
- [ ] Admin API
- [ ] Validation
- [ ] Error handling

---

## Phase 4 — Flutter Foundation

- [ ] Setup theme
- [ ] Setup routing
- [ ] Setup API client
- [ ] Setup secure storage
- [ ] Setup Riverpod
- [ ] Setup responsive layout
- [ ] Setup reusable widgets

---

## Phase 5 — Authentication

- [ ] Splash screen
- [ ] Login
- [ ] Register
- [ ] Logout
- [ ] Token management
- [ ] Auth state
- [ ] Route protection

---

## Phase 6 — User Application

- [ ] Home
- [ ] Vehicle list
- [ ] Vehicle detail
- [ ] Search
- [ ] Filter
- [ ] Favorites
- [ ] Order
- [ ] Order history
- [ ] Profile

---

## Phase 7 — Admin

- [ ] Admin login
- [ ] Dashboard
- [ ] Vehicle management
- [ ] Add vehicle
- [ ] Edit vehicle
- [ ] Delete vehicle
- [ ] Category management
- [ ] User management
- [ ] Order management
- [ ] Statistics

---

# 36. Testing

Testing minimal:

## Unit Test

Test:

```text
Repository
UseCase
Model
Utilities
```

## Widget Test

Test:

```text
Login form
Vehicle card
Vehicle detail
Order form
```

## Integration Test

Test:

```text
Register
Login
Browse vehicle
Favorite
Order
Logout
```

---

# 37. Error Handling

Flutter harus menangani:

```text
No Internet
Server Error
Unauthorized
Forbidden
Not Found
Validation Error
Timeout
Unknown Error
```

Contoh UI:

```text
Unable to connect to server.

Please check your internet connection.

[ Try Again ]
```

Jangan menampilkan error teknis mentah kepada user.

Jangan:

```text
SocketException: Failed host lookup...
```

langsung ditampilkan ke user.

---

# 38. Loading State

Semua request asynchronous harus memiliki state:

```text
Initial
Loading
Success
Error
```

Gunakan:

```text
Skeleton
Progress Indicator
Shimmer
```

sesuai kebutuhan.

Hindari membuat UI terasa freeze ketika request berlangsung.

---

# 39. Empty State

Contoh favorites kosong:

```text
No favorite vehicles yet.

Start exploring vehicles
and save the ones you like.

[ Explore Vehicles ]
```

Order kosong:

```text
No orders yet.

Your future vehicle
is waiting for you.
```

---

# 40. Responsive Design

Breakpoint:

```text
Mobile
< 600px

Tablet
600px - 1024px

Desktop
> 1024px
```

Mobile:

```text
Bottom Navigation
```

Desktop:

```text
Sidebar
```

Contoh:

```text
Mobile

┌───────────────┐
│     YAW       │
├───────────────┤
│               │
│   VEHICLES    │
│               │
├───────────────┤
│ Home Vehicles │
└───────────────┘
```

Desktop:

```text
┌───────┬─────────────────────────┐
│       │                         │
│  YAW  │       CONTENT           │
│       │                         │
│ Home  │                         │
│ Cars  │                         │
│ Fav   │                         │
│ Order │                         │
│ User  │                         │
└───────┴─────────────────────────┘
```

---

# 41. Performance

Perhatikan:

- Image optimization
- Lazy loading
- Pagination
- Caching
- Avoid unnecessary rebuild
- API response size
- Database indexing
- Efficient SQL query

Gunakan format gambar:

```text
WebP
```

jika memungkinkan.

---

# 42. Database Index

Berikan index pada field yang sering digunakan.

Contoh:

```text
users.email
vehicles.slug
vehicles.brand
vehicles.category_id
orders.user_id
orders.status
favorites.user_id
favorites.vehicle_id
```

Tujuan:

```text
Faster query
```

---

# 43. Logging

Backend harus memiliki logging untuk:

```text
Request
Response status
Error
Authentication
Database error
Important system events
```

Namun jangan log:

```text
Password
JWT token
Sensitive information
```

---

# 44. Admin Dashboard Statistics

Dashboard minimal:

```text
Total Vehicles
Total Users
Total Orders
Total Revenue
Pending Orders
Completed Orders
```

Chart:

```text
Sales
Orders
Revenue
Popular Vehicles
```

Contoh:

```text
Revenue

Rp
│
│             ╭───╮
│        ╭────╯   │
│   ╭────╯        ╰──╮
│───╯                 ╰──
└────────────────────────
   Jan Feb Mar Apr May
```

---

# 45. Future Features

Setelah versi pertama selesai, dapat dikembangkan menjadi:

- Online payment
- Test drive booking
- Vehicle comparison
- Financing calculator
- Chat dengan sales
- Push notification
- Promo
- Coupon
- Reviews
- Rating
- Dealer location
- GPS
- Maps
- AI vehicle recommendation
- Dark/light theme
- Multi-language
- Multi-currency
- Real-time notification

Feature tersebut **jangan dibuat di awal**.

Fokus terlebih dahulu pada core system.

---

# 46. MVP

Versi pertama YAW harus fokus pada:

```text
Authentication
      │
      ▼
Vehicle Catalog
      │
      ▼
Vehicle Detail
      │
      ▼
Favorites
      │
      ▼
Order
      │
      ▼
Admin Management
```

MVP:

### User

- Register
- Login
- Browse vehicles
- Search
- Filter
- Detail
- Favorite
- Order
- Order history
- Profile

### Admin

- Login
- Dashboard
- CRUD vehicles
- CRUD categories
- Manage users
- Manage orders

---

# 47. Definition of Done

Sebuah feature dianggap selesai jika:

- [ ] UI selesai
- [ ] Responsive
- [ ] API terhubung
- [ ] Loading state tersedia
- [ ] Error state tersedia
- [ ] Empty state tersedia
- [ ] Validation tersedia
- [ ] Authorization tersedia jika diperlukan
- [ ] Unit test dibuat jika diperlukan
- [ ] Tidak ada debug print yang tidak diperlukan
- [ ] Tidak ada credential hard-coded
- [ ] Code sudah di-format
- [ ] Tidak ada analyzer error

---

# 48. Quality Rules

Code harus:

```text
Readable
Maintainable
Testable
Reusable
Consistent
```

Hindari:

```dart
// giant widget
// duplicate code
// hard-coded API URL
// hard-coded credentials
// database access dari UI
// business logic di Widget
```

Gunakan:

```text
Feature-based architecture
Repository pattern
Dependency injection
State management
Reusable widgets
```

---

# 49. Security Rules

WAJIB:

```text
Never commit .env
Never commit passwords
Never commit JWT secrets
Never store plain passwords
Never expose database publicly
Never connect Flutter directly to MariaDB
Always validate API input
Always authorize admin endpoints
```

Architecture yang benar:

```text
                  INTERNET
                     │
                     ▼
              ┌─────────────┐
              │   Flutter   │
              └──────┬──────┘
                     │
                   HTTPS
                     │
                     ▼
              ┌─────────────┐
              │  REST API   │
              └──────┬──────┘
                     │
                Private Network
                     │
                     ▼
              ┌─────────────┐
              │   MariaDB   │
              └─────────────┘
```

---

# 50. Final Project Structure

Target akhir:

```text
YAW/
│
├── frontend/
│   ├── android/
│   ├── ios/
│   ├── linux/
│   ├── macos/
│   ├── web/
│   ├── windows/
│   │
│   ├── assets/
│   ├── lib/
│   │   ├── app/
│   │   ├── core/
│   │   ├── features/
│   │   └── shared/
│   │
│   ├── test/
│   └── pubspec.yaml
│
├── backend/
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── middlewares/
│   │   ├── models/
│   │   ├── repositories/
│   │   ├── routes/
│   │   ├── services/
│   │   ├── utils/
│   │   └── app.ts
│   │
│   ├── uploads/
│   ├── tests/
│   ├── .env.example
│   └── package.json
│
├── database/
│   ├── migrations/
│   └── seeds/
│
├── docs/
│   ├── API.md
│   ├── DATABASE.md
│   └── ARCHITECTURE.md
│
├── .gitignore
├── README.md
└── PRODUCTION.md
```

---

# 51. Learning Roadmap

Urutan belajar yang disarankan:

```text
1. Flutter basic
       ↓
2. Flutter routing
       ↓
3. Flutter state management
       ↓
4. REST API
       ↓
5. Node.js backend
       ↓
6. MariaDB / SQL
       ↓
7. Authentication
       ↓
8. CRUD
       ↓
9. File upload
       ↓
10. Admin dashboard
       ↓
11. Testing
       ↓
12. Deployment
```

Jangan langsung membuat semua fitur.

Bangun secara bertahap:

```text
Hello Flutter
      ↓
Login
      ↓
Vehicle List
      ↓
Vehicle Detail
      ↓
CRUD
      ↓
Order
      ↓
Admin
      ↓
Production
```

---

# 52. Prinsip Utama Project

YAW adalah **project belajar**, bukan sekadar project untuk selesai cepat.

Prioritaskan:

> **Understand → Build → Test → Refactor → Improve**

Jangan hanya copy-paste code.

Setiap feature yang dibuat harus dipahami:

```text
Kenapa architecture-nya seperti ini?
Kenapa menggunakan API?
Kenapa Flutter tidak langsung ke MariaDB?
Kenapa password harus di-hash?
Kenapa menggunakan JWT?
Kenapa perlu repository?
Kenapa database membutuhkan relationship?
```

Target akhir project bukan hanya:

> "Aplikasi YAW berhasil dibuat."

Tetapi:

> **"Saya memahami bagaimana aplikasi Flutter full-stack dibuat dari frontend, API, database, authentication, sampai deployment."**

---

# 53. First Milestone

Milestone pertama **jangan langsung membuat marketplace lengkap**.

Buat:

```text
YAW
│
├── Flutter
│
├── Backend
│
└── MariaDB
```

Kemudian pastikan flow berikut berhasil:

```text
Flutter
   │
   │ GET /vehicles
   ▼
Backend
   │
   │ SELECT *
   ▼
MariaDB
   │
   ▼
Backend
   │
   ▼
Flutter
   │
   ▼
Vehicle List
```

Setelah flow tersebut berhasil, lanjutkan:

```text
Authentication
      ↓
Vehicle CRUD
      ↓
Favorites
      ↓
Orders
      ↓
Admin Dashboard
```

**Jangan menambahkan payment, chat, AI, notification, atau fitur kompleks lainnya sebelum core system stabil.**