# PERBAIKAN GRADLE UNTUK GITHUB ACTIONS

## Masalah yang Ditemukan

**Error GitHub Actions:**
```
Build was configured to prefer settings repositories over project repositories but repository 'Google' was added by build file 'build.gradle.kts'
```

## Penyebab Masalah

- **Repository didefinisikan di tempat yang salah**: Repository `google()` dan `mavenCentral()` didefinisikan di `android/build.gradle.kts` dalam blok `allprojects`
- **Konfigurasi Gradle modern**: Gradle versi terbaru mengharapkan semua repository didefinisikan di `settings.gradle.kts` di bawah `dependencyResolutionManagement`
- **RepositoriesMode.FAIL_ON_PROJECT_REPOS**: Setting ini menyebabkan build gagal jika ada repository di project files

## Solusi yang Diterapkan

### 1. **Hapus Repository dari `build.gradle.kts`**
```kotlin
// DIHAPUS - Tidak boleh ada repository di sini
allprojects {
    repositories {
        google()
        mavenCentral()
        // ...
    }
}
```

### 2. **Pindahkan Repository ke `settings.gradle.kts`**
```kotlin
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        
        // Repository tambahan untuk menangani error checkReleaseAarMetadata
        maven {
            url = uri("https://repo1.maven.org/maven2")
        }
        
        // Repository untuk plugin file_picker
        maven {
            url = uri("https://maven.google.com")
        }
    }
}
```

### 3. **Pertahankan Konfigurasi Penting Lainnya**
- Build directory configuration
- Subproject configuration
- AAPT options
- Packaging options
- Dependency resolution strategy

## File yang Diperbaiki

1. **`android/build.gradle.kts`** - Dihapus blok `allprojects { repositories { ... } }`
2. **`android/settings.gradle.kts`** - Ditambahkan repository tambahan ke `dependencyResolutionManagement`

## Keuntungan Perbaikan

✅ **GitHub Actions akan berhasil** - Tidak ada lagi error repository  
✅ **Konfigurasi Gradle modern** - Mengikuti best practices terbaru  
✅ **Repository management terpusat** - Semua repository di satu tempat  
✅ **Build lebih konsisten** - Tidak ada konflik repository  

## Verifikasi Perbaikan

Setelah perbaikan, GitHub Actions workflow seharusnya:

1. **Build berhasil** tanpa error repository
2. **APK ter-generate** dengan benar
3. **Semua dependency** terselesaikan dari repository yang benar

## Best Practices untuk Kedepannya

1. **Jangan pernah definisikan repository** di `build.gradle.kts`
2. **Selalu gunakan** `dependencyResolutionManagement` di `settings.gradle.kts`
3. **Gunakan `RepositoriesMode.FAIL_ON_PROJECT_REPOS`** untuk memastikan compliance
4. **Pertahankan konfigurasi build** di `build.gradle.kts` tanpa repository

## Troubleshooting

Jika masih ada masalah:

1. **Pastikan tidak ada repository** di file `build.gradle.kts` manapun
2. **Cek `settings.gradle.kts`** sudah benar
3. **Clean dan rebuild** project
4. **Update Gradle wrapper** jika diperlukan

## Referensi

- [Gradle Documentation: Dependency Resolution Management](https://docs.gradle.org/current/userguide/platforms.html#sub:central-declaration-of-repositories)
- [Android Gradle Plugin Best Practices](https://developer.android.com/studio/build)
- [GitHub Actions Workflow](https://github.com/eki220694/asisten_guru/blob/main/.github/workflows/build.yml)
