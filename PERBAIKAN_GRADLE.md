# Perbaikan Masalah Build Gradle pada Flutter

## Masalah
Ketika membangun aplikasi Flutter untuk Android, terjadi error terkait tipe data pada file `android/build.gradle.kts`:
```
Type mismatch: inferred type is String but File! was expected
```

## Solusi
Masalah ini terjadi karena pada file `android/build.gradle.kts`, properti `buildDir` seharusnya menerima objek bertipe `File`, bukan `String`.

### Perbaikan yang Diperlukan
File `android/build.gradle.kts` harus menggunakan fungsi `file()` untuk mengubah string path menjadi objek File:

```kotlin
// Yang salah:
rootProject.buildDir = "../build"
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}

// Yang benar:
rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}
```

## Langkah-langkah Perbaikan

1. Buka file `android/build.gradle.kts` di editor Anda.

2. Pastikan baris yang mengatur `buildDir` menggunakan fungsi `file()`:
   ```kotlin
   rootProject.buildDir = file("../build")
   subprojects {
       project.buildDir = file("${rootProject.buildDir}/${project.name}")
   }
   ```

3. Simpan perubahan file tersebut.

4. Tambahkan file ke Git:
   ```bash
   git add android/build.gradle.kts
   ```

5. Commit perubahan:
   ```bash
   git commit -m "Fix build.gradle.kts: Ensure buildDir uses File type"
   ```

6. Push perubahan ke repository:
   ```bash
   git push origin main
   ```

Setelah melakukan langkah-langkah di atas, pipeline GitHub Actions seharusnya berhasil membangun aplikasi Android Anda tanpa error tipe data.