# Perbaikan Versi Flutter di GitHub Actions

## Masalah
Project membutuhkan Dart SDK versi ^3.8.1 sesuai dengan konfigurasi di `pubspec.yaml`. Namun, dalam file `.github/workflows/build.yml`, digunakan Flutter versi 3.27.0 yang tidak menyediakan Dart SDK 3.8.1, sehingga menyebabkan kegagalan saat menjalankan `flutter pub get` di GitHub Actions.

## Solusi
Memperbarui konfigurasi GitHub Actions untuk menggunakan Flutter versi 3.32.8 yang menyediakan Dart SDK 3.8.1.

### Perubahan yang Dilakukan
```yaml
# Sebelum
- name: Set up Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.27.0' # Versi yang menyediakan Dart SDK ^3.8.1
    channel: 'stable'

# Setelah
- name: Set up Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.32.8' # Versi yang menyediakan Dart SDK ^3.8.1
    channel: 'stable'
```

## Verifikasi
Setelah perubahan ini, workflow GitHub Actions seharusnya dapat berjalan dengan sukses karena versi Flutter yang digunakan sudah sesuai dengan kebutuhan project.