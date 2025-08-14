# Asisten Guru - Mobile App

Aplikasi mobile untuk membantu guru dalam mengelola data siswa, absensi, kuis, dan membuat RPP dengan AI.

## Perubahan Terbaru
- Memperbaiki inisialisasi database untuk kompatibilitas mobile
- Menghapus dependensi yang tidak diperlukan untuk mobile
- Memastikan semua fitur berjalan dengan baik di perangkat Android

## Fitur Utama
1. **Manajemen Siswa** - Tambah, edit, hapus data siswa
2. **Absensi** - Rekam dan lihat riwayat absensi
3. **Kelas & Mata Pelajaran** - Kelola data kelas dan mapel
4. **Kuis** - Buat dan kelola kuis
5. **RPP AI** - Buat Rencana Pelaksanaan Pembelajaran otomatis
6. **Generator Soal AI** - Buat soal secara otomatis

## Cara Build
1. Pastikan Flutter terinstal
2. Jalankan `flutter pub get`
3. Untuk mobile: `flutter build apk --release`
4. Untuk web: `flutter build web`

## Cara Instalasi
1. Download APK dari GitHub Releases
2. Izinkan instalasi dari sumber tidak dikenal
3. Instal APK
4. Buka aplikasi dan mulai gunakan

## Troubleshooting
Jika mengalami masalah:
1. Pastikan izin penyimpanan diberikan
2. Restart aplikasi jika database tidak merespons
3. Periksa koneksi internet untuk fitur AI