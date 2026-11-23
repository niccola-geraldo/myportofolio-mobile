# myportofolio_mobile

Aplikasi portofolio mobile berbasis Flutter untuk Tutorial 09 dan Tugas 8 tentang navigasi, layout, formulir, dan elemen input.

- `lib/main.dart`: titik masuk aplikasi dan tema Material 3 (indigo dan amber).
- `lib/screens/menu.dart` menampilkan identitas dan empat kartu aksi.
- `lib/widgets/project_card.dart` menampilkan SnackBar ketika kartu ditekan. Kartu **Tambah Proyek** juga membuka formulir. Tombol Back mengembalikan pengguna ke menu.
- `lib/widgets/left_drawer.dart` menyediakan pilihan **Home**, **Add Project**, dan **Add Education**.
- `lib/screens/project_form.dart` memuat formulir proyek. Nama dan deskripsi wajib diisi. Tombol **Save** menampilkan kelima isian dalam dialog konfirmasi. Tombol **OK** menutup dialog dan mengosongkan kolom teks. Kategori terakhir tetap terpilih.

Jalankan aplikasi di Chrome:

```sh
flutter pub get
flutter run -d chrome
```

Periksa kualitas kode dan interaksi antarmuka:

```sh
flutter analyze
flutter test
```

Simpan hasil tutorial ke repositori GitHub yang sudah terhubung:

```sh
git add .
git commit -m "Tutorial 09: Flutter navigation, layouts, forms, and input elements"
git push -u origin feat/tutorial-09
```

Materi sebelumnya: [Tutorial 08](https://pbp.cs.ui.ac.id/tutorial/tutorial-8.html).

### Tugas 7

1. **Apa yang dimaksud dengan widget tree dan bagaimana hubungan parent-child bekerja?**

   Widget tree adalah susunan hierarkis widget yang mendeskripsikan antarmuka Flutter. Widget induk (parent) menyusun widget anak (child) melalui properti seperti `child`, `children`, atau slot khusus seperti `body` dan `appBar`. Satu widget dapat membungkus widget lain untuk memberikan tata letak, tampilan, atau interaksi tertentu.

   Dalam proyek ini, `MyApp` membangun `MaterialApp`, lalu `MyHomePage` menjadi halaman `home`. `MyHomePage` membangun `Scaffold` yang berisi `AppBar` dan `SingleChildScrollView`. Di dalam area yang dapat digulir terdapat `Column` yang menyusun informasi profil dan menu. `Row` menempatkan tiga `InfoCard` secara horizontal, sedangkan `GridView.count` menyusun tiga `ItemCard`. Susunan tersebut membuat setiap bagian memiliki tanggung jawab yang jelas. Saat layout dihitung, parent memberikan batasan ukuran kepada child, kemudian menentukan posisi child berdasarkan ukuran yang dihasilkan.

2. **Widget apa saja yang digunakan dalam proyek ini dan apa fungsinya?**

   Lima widget utama yang digunakan dalam proyek ini adalah:

   | Widget | Fungsi dalam proyek |
   | --- | --- |
   | `MaterialApp` | Mengatur tema, judul, dan halaman awal aplikasi. |
   | `Scaffold` | Menyediakan kerangka halaman, termasuk area judul dan isi. |
   | `Column` | Menyusun elemen secara vertikal, seperti ikon dan teks pada kartu aksi. |
   | `Text` | Menampilkan identitas, judul, label tombol, dan pesan. |
   | `Container` | Mengatur ukuran dan padding konten pada kartu. |

3. **Apa fungsi MaterialApp dan mengapa umumnya digunakan sebagai root widget?**

   `MaterialApp` menyediakan konfigurasi tingkat aplikasi untuk antarmuka Material Design, termasuk tema, navigasi, dan dukungan lokalisasi. Menempatkannya dekat akar widget tree membuat konfigurasi tersebut tersedia bagi halaman-halaman di bawahnya sehingga tampilan dan perilaku aplikasi konsisten.

   Dalam proyek ini, widget yang diberikan kepada `runApp` adalah `MyApp`, lalu `MyApp.build()` mengembalikan `MaterialApp`. Properti `title` bernilai `MyPortfolio`, `theme` mengaktifkan Material 3 dengan warna dasar indigo, dan `home` menampilkan `MyHomePage`. Jadi, `MaterialApp` berperan sebagai pembungkus konfigurasi aplikasi, sedangkan isi halaman disusun oleh `Scaffold` pada `MyHomePage`.

4. **Apa perbedaan StatelessWidget dan StatefulWidget serta kapan digunakan?**

   `StatelessWidget` tidak memiliki objek state internal yang dapat diubah. Tampilan yang dihasilkan bergantung pada konfigurasi widget dan data dari `BuildContext`. Widget ini tetap dapat dibangun ulang ketika parent memberikan konfigurasi baru atau data yang diwarisinya berubah; stateless tidak berarti tampilannya tidak pernah berubah.

   `StatefulWidget` memiliki objek `State` terpisah untuk menyimpan data yang berubah selama widget berada di tree. Ketika data tersebut berubah melalui `setState`, framework menjadwalkan pembangunan ulang tampilan terkait. Objek `StatefulWidget` sendiri tetap immutable.

   Pada proyek ini, `MyHomePage`, `InfoCard`, dan `ItemCard` menggunakan `StatelessWidget` karena hanya menampilkan konfigurasi yang diberikan. Menekan kartu cukup meminta `ScaffoldMessenger` menampilkan SnackBar, tanpa menyimpan state lokal pada kartu. `StatefulWidget` cocok jika nantinya halaman perlu mengelola input formulir, pilihan filter, atau status pemuatan yang berubah selama interaksi pengguna. Penjelasan mengenai konfigurasi dan pembangunan ulang ini sesuai dengan [dokumentasi StatelessWidget](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html).

5. **Apa itu BuildContext, mengapa penting, dan bagaimana penggunaannya dalam build?**

   `BuildContext` adalah objek yang mewakili lokasi sebuah widget dalam tree. Parameter `context` pada `build(BuildContext context)` memungkinkan widget mencari data atau layanan dari ancestor yang sesuai. Karena pencarian bergantung pada posisi dalam tree, context harus berada di bawah penyedia yang ingin diakses.

   Dalam proyek ini, `Theme.of(context).colorScheme.primary` mengambil warna tema untuk `AppBar`, sedangkan `MediaQuery.of(context).size.width` membaca lebar layar untuk konfigurasi `InfoCard`. Pada callback `onTap`, `ScaffoldMessenger.of(context)` memperoleh pengelola SnackBar, menyembunyikan pesan sebelumnya, lalu menampilkan pesan baru. Context dari `MyHomePage` dan kartu berada di bawah `MaterialApp`, sehingga dapat mengakses layanan yang disediakan aplikasi. Lihat [dokumentasi BuildContext](https://api.flutter.dev/flutter/widgets/BuildContext-class.html).

6. **Apa itu hot reload, apa perbedaannya dengan hot restart, dan kapan perlu full restart?**

   Hot reload memasukkan perubahan kode Dart dan membangun ulang widget tree sambil mempertahankan state aplikasi. Fitur ini berguna ketika mengubah teks, warna, atau layout saat pengembangan. Hot reload tidak menjalankan ulang `main()` maupun `initState()`.

   Hot restart menjalankan ulang aplikasi Flutter dari awal dan menghapus state yang sedang berjalan. Gunakan ketika perubahan perlu menjalankan ulang inisialisasi dalam `main()` atau `initState()`, atau ketika perubahan struktur kode tidak dapat diterapkan melalui hot reload.

   Full restart berarti menghentikan dan menjalankan kembali aplikasi, termasuk membangun ulang bagian platform jika diperlukan. Ini dibutuhkan ketika mengubah kode native seperti Kotlin, Java, Swift, atau Objective-C, serta ketika perubahan plugin atau konfigurasi platform memerlukan build ulang. Pada proyek ini, perubahan warna kartu biasanya cukup diperiksa dengan hot reload pada target pengembangan yang mendukungnya; perubahan inisialisasi lebih tepat diperiksa melalui hot restart. Lihat [dokumentasi hot reload Flutter](https://docs.flutter.dev/tools/hot-reload).


### Tugas 8

Pada Tugas 8, kartu **Tambah Edukasi** dan opsi **Add Education** di drawer membuka formulir pendidikan. Formulir menampilkan ringkasan setelah seluruh isian lolos validasi. Jalankan `flutter pub get`, lalu `flutter run -d chrome` untuk mencoba kedua jalur dan kembali lewat **Home** di drawer. Gunakan `flutter analyze` dan `flutter test` untuk memeriksa kode dan alur formulir.

1. **Apa perbedaan `Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`?**

   `push()` meletakkan halaman baru di atas halaman aktif, sehingga tombol kembali dapat menampilkan halaman sebelumnya. Kartu **Tambah Edukasi** menggunakan cara ini. `pushReplacement()` mengganti halaman aktif dan digunakan saat memilih formulir dari drawer. `pop()` menutup rute teratas, misalnya dialog ringkasan, atau menutup drawer yang terbuka. Saat **Home** dipilih, drawer ditutup terlebih dahulu. Jika halaman utama masih ada di tumpukan, `popUntil()` kembali ke halaman tersebut. Jika formulir telah menggantikannya, `pushReplacement()` membuka kembali halaman utama.

2. **Bagaimana `Scaffold`, `AppBar`, dan `Drawer` menjaga konsistensi halaman?**

   `Scaffold` menyediakan tempat untuk bilah judul, isi halaman, dan drawer. `AppBar` menampilkan judul halaman, sedangkan `LeftDrawer` menyediakan opsi navigasi yang sama dari menu utama dan formulir. Misalnya, `AppBar` di menu utama dan formulir edukasi mengambil warna latar dari `Theme.of(context).colorScheme.primary`.

3. **Mengapa formulir menggunakan tata letak ini?**

   `Column` menyusun isian dalam satu alur vertikal. `Padding` memberi ruang di tepi layar dan `SizedBox` memisahkan bidang yang berdekatan. `SingleChildScrollView` memungkinkan pengguna menggulir hingga **Simpan** ketika tinggi layar terbatas atau papan ketik sedang tampil.

4. **Apa peran `GlobalKey<FormState>`, `validator`, dan `validate()` saat Simpan ditekan?**

   `GlobalKey<FormState>` memberi tombol akses ke state formulir. `validate()` menjalankan `validator` setiap bidang dan menampilkan pesan kesalahan dari bidang yang gagal.

## AI Disclosure

Pengerjaan tugas ini dibantu oleh AI.
Tool(s) yang digunakan:
- **opencode**
- **DeepSeek Harness**
- **Codex (OpenAI)**

Model(s) yang digunakan:
- **deepseek-v4.1-flash**

Bagian yang dibantu:
- Implementasi widget pada menu.
- Codex membantu menjelaskan persyaratan tugas, memberikan petunjuk warna kartu, menyusun jawaban refleksi, serta memperbaiki overflow kartu yang ditemukan oleh pengujian.

Semua perubahan telah melalui proses review manual.
