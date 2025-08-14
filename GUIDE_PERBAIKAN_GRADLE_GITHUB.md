# Instruksi Perbaikan Build Gradle untuk GitHub Actions

## Status Saat Ini
Berdasarkan analisis, file `android/build.gradle.kts` di sistem lokal sudah menggunakan fungsi `file()` dengan benar:

```kotlin
rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}
```

Namun, kemungkinan file di repository GitHub masih menggunakan versi yang salah tanpa fungsi `file()`.

## Langkah-langkah Perbaikan

1. **Verifikasi file di repository GitHub**:
   - Buka repository Anda di GitHub
   - Navigasikan ke file `android/build.gradle.kts`
   - Pastikan baris yang mengatur `buildDir` menggunakan fungsi `file()`:
     ```kotlin
     rootProject.buildDir = file("../build")
     subprojects {
         project.buildDir = file("${rootProject.buildDir}/${project.name}")
     }
     ```

2. **Jika file di GitHub belum diperbaiki**:
   - Edit file langsung di GitHub atau
   - Clone repository ke komputer lokal Anda:
     ```bash
     git clone https://github.com/USERNAME/REPO_NAME.git
     ```
   - Perbaiki file `android/build.gradle.kts` sesuai dengan contoh di atas
   - Commit dan push perubahan:
     ```bash
     git add android/build.gradle.kts
     git commit -m "Fix build.gradle.kts: Ensure buildDir uses File type"
     git push origin main
     ```

3. **Jika autentikasi bermasalah**:
   - Pastikan Anda sudah mengatur credential helper:
     ```bash
     git config --global credential.helper store
     ```
   - Atau gunakan token akses pribadi dari GitHub

4. **Setelah push perubahan**:
   - Jalankan kembali GitHub Actions untuk membangun aplikasi
   - Pastikan tidak ada error tipe data lagi

## Catatan Tambahan
File dokumentasi perbaikan juga telah dibuat di `PERBAIKAN_GRADLE.md` untuk referensi masa depan.