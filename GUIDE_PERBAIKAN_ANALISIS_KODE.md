# Perbaikan Masalah Analisis Kode

## Masalah yang Ditemukan

Selama analisis kode dengan `flutter analyze`, ditemukan beberapa masalah serius yang perlu diperbaiki:

1. **Import yang tidak digunakan dan duplikat**:
   - File `lib/database/database_helper.dart` memiliki import `package:path_provider/path_provider.dart` yang tidak digunakan
   - File yang sama juga memiliki duplikasi import `'../models/option.dart'`

2. **Method tidak dikenali**:
   - File `lib/screens/attendance_history_screen.dart` menggunakan `firstWhereOrNull` dan `groupBy` yang tidak dikenali karena tidak mengimpor package yang menyediakan extension method ini

3. **Masalah dengan export soal**:
   - File `lib/screens/question_result_screen.dart` memiliki banyak error terkait:
     - Penggunaan `SharePlus` yang salah
     - Penggunaan `pw` (pdf widgets) yang tidak dikenali
     - Penggunaan `mapIndexed` yang tidak dikenali
     - Penggunaan `pw.Context` yang salah

4. **Masalah dengan export RPP**:
   - File `lib/screens/rpp_ai_result_screen.dart` memiliki error terkait:
     - Variabel `file` yang dideklarasikan dua kali
     - Variabel `htmlContent` dan `utf8` yang tidak didefinisikan
     - Penggunaan `SharePlus` yang salah

## Perbaikan yang Dilakukan

1. **Memperbaiki import di `database_helper.dart`**:
   - Menghapus import `package:path_provider/path_provider.dart` yang tidak digunakan
   - Menghapus duplikasi import `'../models/option.dart'`

2. **Menambahkan import yang diperlukan di `attendance_history_screen.dart`**:
   - Menambahkan `import 'package:collection/collection.dart';` untuk menyediakan method `firstWhereOrNull` dan `groupBy`

3. **Memperbaiki export soal di `question_result_screen.dart`**:
   - Menambahkan import yang diperlukan:
     - `import 'package:collection/collection.dart';`
     - `import 'package:pdf/pdf.dart';`
     - `import 'package:pdf/widgets.dart' as pw;`
   - Memperbaiki penggunaan `SharePlus` menjadi `Share`
   - Memperbaiki penggunaan `pw.Context` menjadi `context`
   - Memperbaiki penggunaan `XFile` yang tidak diperlukan

4. **Memperbaiki export RPP di `rpp_ai_result_screen.dart`**:
   - Menghapus deklarasi variabel `file` yang duplikat
   - Menghapus penggunaan variabel `htmlContent` dan `utf8` yang tidak didefinisikan
   - Memperbaiki penggunaan `SharePlus` menjadi `Share`

## Verifikasi

Setelah perubahan ini, semua error yang ditemukan sebelumnya seharusnya sudah diperbaiki. Perlu dijalankan `flutter analyze` kembali untuk memastikan tidak ada error tersisa.