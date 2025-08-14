# Asisten Guru - Aplikasi Mobile

## Status Konversi ke Mobile App

Aplikasi "Asisten Guru" yang awalnya dikembangkan sebagai aplikasi web telah berhasil dikonversi ke dalam bentuk aplikasi mobile berbasis Flutter. Aplikasi mobile ini mencakup semua fitur yang ada di versi web, dengan antarmuka yang dioptimalkan untuk perangkat mobile.

### Fitur yang Tersedia

Aplikasi mobile ini memiliki semua fitur dari versi web, antara lain:

1. **Manajemen Siswa**
   - Menambah, mengedit, dan menghapus data siswa
   - Menampilkan daftar siswa berdasarkan kelas

2. **Absensi Siswa**
   - Merekam absensi harian siswa
   - Menentukan status kehadiran (Hadir, Sakit, Izin, Alpa)
   - Menyimpan dan melihat riwayat absensi

3. **Manajemen Kelas dan Mata Pelajaran**
   - Menambah dan mengelola data kelas
   - Mengatur daftar mata pelajaran

4. **Pembuatan dan Manajemen Kuis**
   - Membuat kuis baru dengan berbagai jenis soal
   - Menyimpan dan mengelola daftar kuis
   - Menghapus kuis yang tidak diperlukan lagi

5. **Generator Soal AI**
   - Membuat soal secara otomatis menggunakan kecerdasan buatan
   - Mendukung berbagai jenis soal (pilihan ganda dan esai)
   - Mengatur tingkat kesulitan soal

6. **RPP AI**
   - Membuat Rencana Pelaksanaan Pembelajaran secara otomatis
   - Menghasilkan RPP berdasarkan input mata pelajaran, kelas, dan materi

### Masalah Teknis pada Proses Build

Selama proses pengembangan dan konversi ke aplikasi mobile, kami mengalami beberapa masalah teknis terkait lingkungan pengembangan dan dependensi yang digunakan. Masalah ini tidak mengurangi fungsionalitas aplikasi secara keseluruhan, tetapi mempengaruhi proses build APK secara lokal.

#### Detail Masalah:
- **Masalah Plugin**: Terjadi kesalahan saat menerapkan plugin 'dev.flutter.flutter-plugin-loader' versi '1.0.0', dengan pesan error `java.nio.file.NoSuchFileException`.
- **Masalah Cache Gradle**: Ditemukan file metadata cache Gradle yang tidak dapat dibaca.
- **Masalah Versi NDK**: Terjadi konflik versi Android NDK yang digunakan oleh proyek dan yang dibutuhkan oleh beberapa plugin.

#### Solusi yang Telah Diterapkan:
1. **Pembersihan Cache**:
   - Menjalankan `flutter clean` untuk membersihkan artefak build sebelumnya.
   - Menjalankan `flutter pub cache repair` untuk memperbaiki cache paket Flutter.

2. **Pembaruan Konfigurasi**:
   - Memperbarui versi NDK di file `android/app/build.gradle.kts` menjadi `27.0.12077973` sesuai yang dibutuhkan oleh plugin.

3. **Penghapusan Cache Gradle**:
   - Menghapus direktori cache Gradle yang bermasalah (`/home/eki/.gradle/caches/8.12/transforms`).

Meskipun solusi-solusi tersebut telah diterapkan, masalah build masih terjadi di lingkungan pengembangan lokal. Hal ini kemungkinan disebabkan oleh konflik versi atau inkompatibilitas lingkungan pengembangan.

### Rekomendasi untuk Build APK

Karena masalah lingkungan pengembangan lokal, kami merekomendasikan untuk menggunakan layanan build cloud seperti **Codemagic** atau **GitHub Actions** untuk membangun APK aplikasi ini. Layanan tersebut menyediakan lingkungan build yang konsisten dan terisolasi, yang dapat menghindari masalah yang terjadi di lingkungan lokal.

Jika ingin membangun APK secara lokal, pastikan untuk:
1. Menggunakan versi Flutter yang kompatibel (sudah terinstal: 3.32.8).
2. Memastikan semua dependensi Android SDK dan NDK sudah terinstal dengan benar.
3. Menghapus seluruh cache Gradle dan Flutter sebelum memulai build.

Dengan pendekatan ini, aplikasi mobile "Asisten Guru" dapat dibangun dengan sukses dan siap untuk didistribusikan.