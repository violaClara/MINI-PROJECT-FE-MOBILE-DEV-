# Work Focus App

Work Focus adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu Anda mengelola waktu kerja, meningkatkan produktivitas, dan mendapatkan insight mendalam tentang kebiasaan kerja harian Anda.

---

## 📌 Daftar Isi

- [📖 Overview](#overview)
- [🚀 Fitur Utama](#fitur-utama)
- [📂 Arsitektur & Struktur Proyek](#arsitektur--struktur-proyek)
- [⚙️ Getting Started](#getting-started)
- [📝 Panduan Penggunaan](#panduan-penggunaan)
- [🤝 Kontribusi](#kontribusi)
- [📜 Lisensi](#lisensi)

---

## 📖 Overview

Aplikasi ini membantu Anda untuk:
- ✅ **Memantau waktu kerja secara real-time** dengan gauge interaktif.
- ✅ **Mengatur target kerja harian** sesuai kebutuhan.
- ✅ **Melihat analitik dan insight** berupa work streaks serta tren kebiasaan kerja.
- ✅ **Mengelola profil dan pengaturan akun** dengan fitur autentikasi yang aman.

---

## 🚀 Fitur Utama

✨ **Real-Time Work Log:**  
Melacak durasi kerja secara langsung dan menampilkan progres dalam format visual yang menarik.

🎯 **Target Harian yang Dapat Disesuaikan:**  
Atur target jam kerja harian dan lihat sisa waktu untuk mencapai target tersebut.

📊 **Insight & Analytics:**  
Tampilkan data visual mengenai pencapaian kerja, work streaks, dan tren kontribusi melalui grafik serta grid kontribusi.

🔒 **Autentikasi Pengguna:**  
Fitur login dan sign up yang aman dengan penggunaan Provider untuk manajemen state.

👤 **Manajemen Profil:**  
Update informasi profil, kelola data & privasi, serta ubah password dengan mudah.

---

## 📂 Arsitektur & Struktur Proyek

Aplikasi ini dibangun dengan Flutter menggunakan arsitektur berbasis Provider untuk state management. Struktur proyek:

```bash
lib/
├── controllers/         # Logika bisnis & pengelolaan state (contoh: AuthController, TargetController)
├── screens/             # Tampilan UI utama (HomeScreen, InsightScreen, LoginScreen, ProfileScreen)
├── widgets/             # Komponen UI reusable (BottomNavBar, ProgressBox, dll.)
└── main.dart            # Titik awal aplikasi
```

---

## ⚙️ Getting Started

Ikuti langkah berikut untuk menjalankan aplikasi secara lokal atau install aplikasi di mobile devices (.apk):

### 1️⃣ Clone Repository:

```bash
git clone https://github.com/username/akusoftware-workfocus.git
cd akusoftware-workfocus
```

### 2️⃣ Install Dependencies:

Pastikan Flutter sudah terinstal, lalu jalankan:

```bash
flutter pub get
```

### 3️⃣ Jalankan Aplikasi:

Gunakan perintah berikut untuk menjalankan aplikasi pada emulator atau perangkat fisik:

```bash
flutter run
```

---

## 📝 Panduan Penggunaan

🟢 **Login / Sign Up:**  
Masuk menggunakan akun Anda atau daftar akun baru di layar Login dengan memilih mode yang sesuai.

🟢 **Atur Target Harian:**  
Saat pertama kali menggunakan aplikasi, Anda akan diminta mengatur target jam kerja harian. Target ini digunakan untuk menghitung sisa waktu dan progres kerja.

🟢 **Dashboard:**  
Lihat akumulasi waktu kerja, sisa waktu untuk mencapai target, serta progres yang ditampilkan melalui gauge dan progress bar interaktif.

🟢 **Insight & Analytics:**  
Dapatkan data performa kerja harian, work streaks, dan tren kontribusi kerja selama satu tahun.

🟢 **Manajemen Profil:**  
Perbarui informasi pribadi, kelola data & privasi, serta ubah password melalui layar Profile.

---

## 🤝 Kontribusi

Kami mengundang Anda untuk berkontribusi mengembangkan Work Focus. Jika ingin memberikan perbaikan atau fitur baru, silakan:

1. **Fork** repository ini.
2. Buat branch baru untuk perubahan yang Anda inginkan.
3. Lakukan commit dan push perubahan.
4. Buat Pull Request dan jelaskan perubahan yang telah dilakukan.

---

## 📜 Lisensi

Work Focus dilisensikan di bawah [MIT License](LICENSE).

---

**🎯 Track Your Work. Master Your Focus.**
