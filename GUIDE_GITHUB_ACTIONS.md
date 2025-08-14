# Cara Build Aplikasi Mobile dengan GitHub Actions

## Langkah-langkah:

1. **Commit dan Push File Konfigurasi**
   - File `.github/workflows/build.yml` sudah dibuat
   - Commit file ini ke repository GitHub Anda

2. **Akses GitHub Actions**
   - Buka repository di GitHub
   - Klik tab "Actions" di bagian atas

3. **Proses Build Otomatis**
   - Setiap kali Anda push ke branch main/master, build akan otomatis berjalan
   - Anda juga bisa menjalankan build manual dari antarmuka GitHub

4. **Mengunduh APK**
   - Setelah build selesai:
     - Klik workflow yang berhasil
     - Scroll ke bagian bawah
     - Klik "app-release.apk" di bagian Artifacts untuk mengunduh

5. **Release Otomatis** (Opsional)
   - Setiap build sukses dari branch utama akan membuat release baru
   - APK bisa diunduh dari tab "Releases" di repository

## Catatan Penting:
- Build pertama mungkin memakan waktu 10-15 menit karena perlu setup environment
- Build selanjutnya akan lebih cepat karena caching
- File APK yang dihasilkan siap diinstal di perangkat Android

## Troubleshooting:
Jika terjadi error:
1. Cek log di tab GitHub Actions
2. Pastikan tidak ada error dalam kode Flutter
3. Jika ada masalah, bisa dibagi log errornya untuk bantuan lebih lanjut