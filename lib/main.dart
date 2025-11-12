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
import 'package:simaru/models/user_profile.dart';
import 'package:simaru/services/room_service.dart';

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
    Map<String, dynamic>? extractProfile(dynamic payload) {
      if (payload == null) {
        return null;
      }

      if (payload is Map) {
        final dynamic direct =
            payload['user'] ??
            payload['profile'] ??
            payload['data'] ??
            payload['account'];
        if (direct is Map<String, dynamic>) {
          return direct;
        }
        if (direct is Map) {
          return Map<String, dynamic>.from(direct);
        }

        if (_containsProfileKeys(payload)) {
          return Map<String, dynamic>.from(
            payload.map((key, value) => MapEntry(key.toString(), value)),
          );
        }

        for (final value in payload.values) {
          if (value is Map || value is Iterable) {
            final nested = extractProfile(value);
            if (nested != null && nested.isNotEmpty) {
              return nested;
            }
          }
        }
      }

      if (payload is Iterable) {
        for (final element in payload) {
          final nested = extractProfile(element);
          if (nested != null && nested.isNotEmpty) {
            return nested;
          }
        }
      }

      return null;
    }

    String? extractUserName(dynamic payload) {
      if (payload == null) {
        return null;
      }

      if (payload is String) {
        final trimmed = payload.trim();
        return trimmed.isNotEmpty ? trimmed : null;
      }

      if (payload is Iterable) {
        for (final element in payload) {
          final candidate = extractUserName(element);
          if (candidate != null && candidate.isNotEmpty) {
            return candidate;
          }
        }
        return null;
      }

      if (payload is Map) {
        for (final entry in payload.entries) {
          final keyString = entry.key.toString().toLowerCase();
          final value = entry.value;

          if (value is String) {
            if ((keyString.contains('name') || keyString.contains('nama')) &&
                value.trim().isNotEmpty) {
              return value.trim();
            }
          }
        }

        for (final value in payload.values) {
          if (value is Map || value is Iterable) {
            final nestedResult = extractUserName(value);
            if (nestedResult != null && nestedResult.isNotEmpty) {
              return nestedResult;
            }
          }
        }
      }

      return null;
    }

    String? extractToken(dynamic payload) {
      if (payload == null) {
        return null;
      }

      if (payload is Map) {
        const tokenKeys = [
          'accessToken',
          'access_token',
          'token',
          'api_token',
          'bearer_token',
        ];

        for (final key in tokenKeys) {
          final value = payload[key];
          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
        }

        for (final value in payload.values) {
          if (value is Map || value is Iterable) {
            final nested = extractToken(value);
            if (nested != null && nested.isNotEmpty) {
              return nested;
            }
          }
        }
      }

      if (payload is Iterable) {
        for (final element in payload) {
          final nested = extractToken(element);
          if (nested != null && nested.isNotEmpty) {
            return nested;
          }
        }
      }

      return null;
    }

    final dynamic arguments = Get.arguments;
    final profileMap = extractProfile(arguments);
    final initialUserName =
        extractUserName(arguments) ?? profileMap?['name'] as String?;
    final token = extractToken(arguments);

    UserProfile? initialProfile;
    if (profileMap != null && profileMap.isNotEmpty) {
      try {
        initialProfile = UserProfile.fromMap(profileMap);
      } catch (e) {
        debugPrint('HomeBinding: Failed to parse user profile: $e');
      }
    }

    Get.lazyPut(() => RoomService());
    Get.lazyPut(
      () => HomeController(
        initialUserName: initialUserName,
        initialUserProfile: initialProfile,
        initialAccessToken: token,
      ),
    );
    // Jika Home membutuhkan service, daftarkan di sini
    // Get.lazyPut(() => HomeService());
  }

  bool _containsProfileKeys(Map<dynamic, dynamic> map) {
    const candidates = ['name', 'nama', 'email', 'email_address', 'phone'];
    for (final entry in map.entries) {
      final key = entry.key.toString().toLowerCase();
      if (entry.value is String &&
          candidates.any((candidate) => key.contains(candidate))) {
        return true;
      }
    }
    return false;
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
