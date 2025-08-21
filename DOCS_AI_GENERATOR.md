# Panduan Penggunaan Fitur AI Generator Soal

## Persyaratan

Untuk menggunakan fitur AI Generator Soal yang ditingkatkan, Anda perlu:

1. **OpenAI API Key**
   - Daftar di [OpenAI Platform](https://platform.openai.com/)
   - Dapatkan API key Anda

2. **Koneksi Internet**
   - Fitur ini memerlukan koneksi internet untuk menghubungi API OpenAI

## Cara Mengatur API Key

### Untuk Development Lokal:

```bash
# Export API key sebagai environment variable
export OPENAI_API_KEY=sk-YOUR_API_KEY_HERE

# Jalankan aplikasi Flutter
flutter run
```

### Untuk Production:

API key harus diatur di sisi server atau menggunakan mekanisme secret management yang aman.

## Cara Menggunakan Fitur

1. **Buka Aplikasi**
   - Jalankan aplikasi Asisten Guru

2. **Navigasi ke Menu Generator Soal**
   - Pilih menu "Generator Soal AI"

3. **Isi Formulir**
   - **Mata Pelajaran**: Masukkan mata pelajaran (misal: Matematika)
   - **Kelas**: Masukkan tingkat kelas (misal: 10)
   - **Materi**: Masukkan materi pembelajaran atau unggah file
   - **Jumlah Soal**: Tentukan berapa banyak soal yang ingin dibuat
   - **Tipe Soal**: Pilih antara Pilihan Ganda, Essai, atau Campuran
   - **Tingkat Kesulitan**: Pilih Mudah, Sedang, atau Sulit

4. **Unggah File (Opsional)**
   - Klik tombol unggah file untuk memasukkan materi dari file
   - Format yang didukung: TXT, DOC, DOCX, PDF

5. **Generate Soal**
   - Klik tombol "Buat Soal Sekarang"
   - Tunggu beberapa saat hingga AI memproses permintaan

## Keuntungan Fitur yang Ditingkatkan

1. **Kualitas Soal Lebih Baik**
   - Soal dibuat oleh AI canggih (GPT-3.5-turbo atau GPT-4)
   - Relevansi tinggi dengan materi yang diberikan

2. **Format Konsisten**
   - Struktur soal yang seragam dan mudah dibaca
   - Pemisahan jelas antara soal dan jawaban

3. **Customizable**
   - Sesuaikan jumlah soal, tipe, dan tingkat kesulitan
   - Mendukung berbagai mata pelajaran dan tingkat kelas

4. **Fallback Mechanism**
   - Jika AI service tidak tersedia, otomatis menggunakan implementasi lokal
   - Memastikan fitur tetap berfungsi dalam berbagai kondisi

## Troubleshooting

### Masalah Umum:

1. **"API key tidak ditemukan"**
   - Pastikan API key telah diatur dengan benar
   - Periksa koneksi internet

2. **Soal tidak muncul atau format tidak sesuai**
   - Coba refresh atau restart aplikasi
   - Pastikan materi yang diberikan cukup jelas dan lengkap

3. **Waktu tunggu terlalu lama**
   - Koneksi internet lambat
   - Server AI sedang sibuk, coba beberapa saat lagi

### Kontak Support:

Jika mengalami masalah yang tidak bisa diselesaikan, hubungi developer atau buat issue di repository GitHub.