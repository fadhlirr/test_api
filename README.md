# Take Home Test

## Goals

1. **Implementasikan Unit Test**
   - Buatlah unit test yang komprehensif untuk memastikan semua fungsi dalam proyek ini bekerja seperti yang diharapkan.
   - Pastikan semua tes berjalan dengan baik dan mencapai tingkat cakupan yang memadai.

2. **Implementasikan Caching** (Optional)
   - Tambahkan mekanisme caching untuk meningkatkan performa aplikasi.
   - Pastikan bahwa sistem caching berfungsi dengan baik dan tidak mengganggu logika utama aplikasi.

## Poin Penilaian

Ketika menyelesaikan tugas ini, kami akan menilai:

- Kualitas dan cakupan unit test.
- Implementasi caching (optional).
- Kualitas refactoring dan keterbacaan kode.

## Note
- Anda bisa menggunakan gem rspec untuk unit test
- Anda bisa menggunakan cache built-in rails atau third party sesuai pilihan Anda
-


## Cara Menjalankan Proyek Secara Lokal

Untuk menjalankan proyek ini secara lokal, pastikan Anda sudah menginstal Docker dan Docker Compose. Kemudian, jalankan perintah berikut:

```bash
docker-compose up --build
```

Setelah container berjalan, aplikasi akan tersedia dan siap untuk diuji.

### Menjalankan RSpec

Untuk menjalankan semua tes menggunakan RSpec, jalankan perintah berikut di terminal:

```bash
docker exec -it interview_test_api-app-1 bundle exec rspec
```

Pastikan container sudah aktif sebelum menjalankan perintah di atas.

