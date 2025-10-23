import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/services/register_service.dart';

class LoginController extends GetxController {
  // Instance RegisterService didaftarkan saat controller ini dibuat
  final RegisterService _service = Get.put(RegisterService());

  // State untuk loading, .obs membuatnya reaktif
  var isLoading = false.obs;

  // Controller untuk TextField
  final nameController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final passwordConfirmation = passwordConfirmationController.text.trim();

    // Validasi input sederhana
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan Password harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true; // Mulai loading -> UI akan update via Obx

      // Panggil service untuk login
      final response = await _service.register(
        name,
        email,
        password,
        passwordConfirmation,
      );

      // Cek response dari API
      if (response != null && response['accessToken'] != null) {
        String userName = response['user']?['name'] ?? 'Pengguna Baru';

        Get.snackbar(
          'Sukses',
          'Login berhasil',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed('/home', arguments: userName);
      } else {
        // Jika response tidak valid atau tidak ada accessToken
        Get.snackbar(
          'Gagal',
          'Email atau password salah',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Tangani error jika terjadi saat pemanggilan API
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false; // Hentikan loading -> UI akan update
    }
  }

  // Bersihkan controller TextField saat controller ini tidak digunakan lagi
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
