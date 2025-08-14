# Perbaikan Versi Gradle untuk Build Android

## Masalah
Project mengalami kegagalan build di GitHub Actions dengan error:
```
Minimum supported Gradle version is 8.9. Current version is 8.4. If using the gradle wrapper, try editing the distributionUrl in /home/runner/work/asisten_guru/asisten_guru/android/gradle/wrapper/gradle-wrapper.properties to gradle-8.9-all.zip
```

Ini terjadi karena versi Gradle yang digunakan (8.4) lebih rendah dari versi minimum yang dibutuhkan oleh plugin Android versi 8.7.3 (8.9).

## Solusi
Memperbarui file `gradle-wrapper.properties` untuk menggunakan Gradle versi 8.9.

### Perubahan yang Dilakukan
```properties
# Sebelum
distributionUrl=https\://services.gradle.org/distributions/gradle-8.4-all.zip

# Setelah
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-all.zip
```

## Verifikasi
Setelah perubahan ini, build Android seharusnya dapat berjalan dengan sukses di GitHub Actions karena versi Gradle sudah sesuai dengan kebutuhan plugin Android.