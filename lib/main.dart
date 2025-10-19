import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/controllers/home_controller.dart';
import 'package:simaru/controllers/login_controller.dart';
import 'package:simaru/screens/home_screen.dart';
import 'package:simaru/screens/login_screen.dart';
// Anda mungkin perlu mengimpor LoginService jika mendaftarkannya di LoginBinding
// import 'package:simaru/services/login_service.dart';

void main() async {
  // Pastikan Flutter binding siap sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  // Anda bisa inisialisasi GetStorage di sini jika menggunakannya nanti
  // await GetStorage.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Nonaktifkan banner debug
      debugShowCheckedModeBanner: false,
      title: 'Simaru App',
      // Pengaturan tema dasar
      theme: ThemeData(
        primaryColor: const Color(0xFF592974), // Warna utama
        // Gunakan Material 3 design system
        useMaterial3: true,
        // Anda bisa kustomisasi tema lebih lanjut di sini
        // colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003366)),
        // appBarTheme: AppBarTheme(backgroundColor: const Color(0xFF003366)),
      ),

      // Menggunakan GetX Route Management
      initialRoute: '/login', // Tentukan halaman awal saat aplikasi dibuka
      // Daftar semua halaman/rute aplikasi Anda
      getPages: [
        GetPage(
          name: '/login', // Nama rute untuk halaman login
          page: () => const LoginScreen(), // Widget yang akan ditampilkan
          binding: LoginBinding(), // Binding yang terkait dengan rute ini
        ),
        GetPage(
          name: '/home', // Nama rute untuk halaman home/dashboard
          page: () => const HomeScreen(), // Widget yang akan ditampilkan
          binding: HomeBinding(), // Binding yang terkait dengan rute ini
        ),
        // Tambahkan GetPage lain di sini untuk halaman berikutnya
        // Misal: GetPage(name: '/pinjam', page: () => PinjamScreen(), binding: PinjamBinding()),
      ],
    );
  }
}

// === Bindings ===
// Kelas ini bertanggung jawab untuk mendaftarkan dependencies (Controllers, Services)
// yang dibutuhkan oleh sebuah halaman/rute.

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut mendaftarkan controller tapi baru membuatnya saat pertama kali dibutuhkan.
    // Ini lebih hemat memori daripada Get.put().
    Get.lazyPut(() => LoginController());

    // LoginService sudah di-put di dalam LoginController, jadi tidak perlu di sini.
    // Jika Anda ingin mendaftarkannya di sini:
    // Get.lazyPut(() => LoginService());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Mendaftarkan HomeController saat rute '/home' diakses.
    Get.lazyPut(() => HomeController());
  }
}

// Buat kelas Binding lain untuk setiap rute yang membutuhkan controller/service
// class PinjamBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut(() => PinjamController());
//     Get.lazyPut(() => RuanganService()); 
//   }
// }