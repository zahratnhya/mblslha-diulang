# Campus Planner

Aplikasi manajemen jadwal dan tugas untuk mahasiswa yang membantu mengorganisir aktivitas akademik dengan lebih efisien.

## 📱 Tentang Aplikasi

**Campus Planner** adalah aplikasi mobile berbasis Flutter yang dirancang khusus untuk membantu mahasiswa dalam mengelola jadwal kuliah, tugas (assignments), catatan (notes), dan aktivitas harian. Aplikasi ini menyediakan antarmuka yang intuitif untuk meningkatkan produktivitas dan mengatur waktu dengan lebih baik.

### Fitur Utama

- 📚 **Manajemen Tugas (Assignments)** - Kelola tugas kuliah dengan deadline, status completion, dan reminder
- 📅 **Jadwal Kuliah (Schedule)** - Atur jadwal kelas, event, dan meeting dengan fitur recurring schedule
- 📝 **Catatan (Notes)** - Buat dan kelola catatan penting untuk kuliah atau keperluan lainnya
- ✅ **Task Today** - Catat dan pantau tugas harian yang perlu diselesaikan hari ini
- 👤 **Manajemen Profil** - Update informasi pribadi, kampus, jurusan, semester, dan foto profil
- 🔐 **Autentikasi** - Sistem login yang aman untuk melindungi data pengguna

## 🏗️ Arsitektur Aplikasi

Aplikasi menggunakan **Layered Architecture** yang memisahkan tanggung jawab menjadi tiga lapisan:

```
UI (Pages) 
    ↓
Repository (Business Logic)
    ↓
Service (HTTP API Client)
    ↓
Backend API
```

### Struktur Lapisan

1. **Presentation Layer (UI/Pages)**
   - LoginPage, HomePage, ProfilePage
   - AssignmentsPage, NotesPage, SchedulePage
   - Bertanggung jawab untuk tampilan dan interaksi pengguna

2. **Business Logic Layer (Repository)**
   - AuthRepository, HomeRepository, AssignmentRepository
   - NotesRepository, ScheduleRepository, TaskRepository, ProfileRepository
   - Mengatur alur data, validasi, dan pemrosesan logika bisnis

3. **Data Layer (Service/API Client)**
   - AuthService, AssignmentService, NotesService
   - ScheduleService, TaskService, ProfileService, HomeService
   - Berkomunikasi dengan backend melalui HTTP requests

## 🔌 API Endpoints

Base URL: `https://zahraapi.xyz/campus_api/index.php`

### Authentication
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `?path=users&action=login` | Login pengguna |

**Request Body:**
```json
{
  "email": "example@gmail.com",
  "password": "123456"
}
```

### Assignments (Tasks)
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `?path=tasks&user_id={ID}` | Ambil semua assignment |
| POST | `?path=tasks` | Buat assignment baru |
| PUT | `?path=tasks&id={ID}` | Update assignment |
| DELETE | `?path=tasks&id={ID}` | Hapus assignment |

**Request Body (POST/PUT):**
```json
{
  "user_id": 1,
  "title": "Tugas Pemrograman",
  "description": "Bab 1-3",
  "time": "08:00",
  "deadline": "2025-01-20",
  "status": 0
}
```

### Notes
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `?path=notes&user_id={ID}` | Ambil semua notes |
| POST | `?path=notes` | Buat note baru |
| PUT | `?path=notes&id={ID}` | Update note |
| DELETE | `?path=notes&id={ID}` | Hapus note |

### Schedule
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `?path=schedule&user_id={ID}&date={YYYY-MM-DD}` | Ambil jadwal |
| POST | `?path=schedule` | Buat jadwal baru |
| PUT | `?path=schedule&id={ID}` | Update jadwal |
| DELETE | `?path=schedule&id={ID}` | Hapus jadwal |

**Fitur Khusus:**
- Mendukung recurring schedule (jadwal berulang mingguan)
- Menyimpan lokasi, dosen, dan catatan tambahan

### Task Today
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `?path=tasktoday&user_id={ID}` | Ambil task hari ini |
| POST | `?path=tasktoday` | Buat task hari ini |
| PUT | `?path=tasktoday&id={ID}` | Update task |
| DELETE | `?path=tasktoday&id={ID}` | Hapus task |

### Profile (Users)
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `?path=users&id={ID}` | Ambil data profil |
| PUT | `?path=users&id={ID}` | Update profil |

**Update Profil Support:**
- Nama, email, kampus, jurusan, semester
- Upload foto profil (Base64)
- Hapus foto profil

### Format Response
**Success:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": [...]
}
```

**Error:**
```json
{
  "success": false,
  "message": "Error message"
}
```

## 🚀 Instalasi

### Prasyarat
- Flutter SDK (versi 3.0 atau lebih baru)
- Dart SDK
- Android Studio / VS Code dengan plugin Flutter
- Emulator Android atau perangkat fisik untuk testing

### Langkah Instalasi

1. **Clone Repository**
```bash
git clone <repository-url>
cd campus-planner
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Konfigurasi API**
   - Pastikan base URL API sudah sesuai di file service
   - Base URL: `https://zahraapi.xyz/campus_api/index.php`

4. **Run Aplikasi**
```bash
# Jalankan di debug mode
flutter run

# Atau build APK
flutter build apk --release
```

5. **Testing**
```bash
# Run unit tests
flutter test
```

## 📂 Struktur Folder

```
lib/
├── main.dart

├── pages/                          # Semua UI Pages
│   ├── login_page.dart
│   ├── home_page.dart
│   ├── main_navigation.dart
│   ├── add_assignment_page.dart
│   ├── edit_assignment_page.dart
│   ├── assignments_page.dart
│   ├── assignments_detail_page.dart
│   ├── add_schedule_page.dart
│   ├── schedule_page.dart
│   ├── schedule_detail_page.dart
│   ├── add_task_page.dart
│   ├── notes_page.dart
│   ├── profile_page.dart

├── repositories/                   # Layer Repository (Business Logic)
│   ├── auth_repository.dart
│   ├── assigment_repository.dart
│   ├── home_repository.dart
│   ├── notes_repository.dart
│   ├── schedule_repository.dart
│   ├── profile_repository.dart
│   └── task_repository.dart

├── services/                       # API Service Layer
│   ├── auth_service.dart
│   ├── assignment_service.dart
│   ├── home_service.dart
│   ├── notes_service.dart
│   ├── schedule_service.dart
│   ├── profile_service.dart
│   └── task_service.dart

├── utils/                          # Utility Files
│   └── network_wrrapper.dart

└── widgets/                        # Component Widgets
    ├── network_checker_widget.dart
    ├── network_status_indicator.dart
    └── main.dart

```

## 👨‍💻 Developer

**Zahra Tunnihaya Romo**
- NIM: 230605110141
- Kelas: A
- Program Studi: Teknik Informatika
- Fakultas Sains dan Teknologi
- Universitas Islam Negeri Maulana Malik Ibrahim Malang

## 📝 Lisensi

Project ini dibuat untuk keperluan akademik - Mobile Programming (Ganjil 2025/2026)

---

**Tanggal Pembuatan:** 08 Desember 2025
