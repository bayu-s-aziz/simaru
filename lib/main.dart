import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/controllers/home_controller.dart';
import 'package:simaru/controllers/login_controller.dart';
import 'package:simaru/controllers/register_controller.dart'; // Import RegisterController
import 'package:simaru/screens/home_screen.dart';
import 'package:simaru/screens/login_screen.dart';
import 'package:simaru/screens/register_screen.dart'; // Import RegisterScreen
import 'package:simaru/services/login_service.dart'; // Import LoginService
import 'package:simaru/services/register_service.dart'; // Import RegisterService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simaru App',
      theme: ThemeData(
        primaryColor: const Color(0xFF592974), // Warna utama
        // Gunakan Material 3 design system
        useMaterial3: true,
        // Definisikan colorScheme agar konsisten
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF592974)),
        appBarTheme: const AppBarTheme(
          // Style AppBar default
          backgroundColor: Color(0xFF592974),
          foregroundColor: Colors.white, // Warna teks & ikon di AppBar
          iconTheme: IconThemeData(color: Colors.white), // Warna ikon back
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      initialRoute: '/login', // Halaman awal
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          binding: LoginBinding(), // Binding untuk login
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          binding: HomeBinding(), // Binding untuk home
        ),
        // --- Tambahkan Route & Binding untuk Register ---
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
          binding: RegisterBinding(), // Binding untuk register
        ),
        // --- Akhir Route Register ---
      ],
    );
  }
}

// === Bindings ===

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    // Daftarkan service agar bisa di-find di controller
    Get.lazyPut(() => LoginService());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    // Jika Home membutuhkan service, daftarkan di sini
    // Get.lazyPut(() => HomeService());
  }
}

// --- Tambahkan Binding untuk Register ---
class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RegisterController());
    // Daftarkan service agar bisa di-find di controller
    Get.lazyPut(() => RegisterService());
  }
}
// --- Akhir Binding Register ---