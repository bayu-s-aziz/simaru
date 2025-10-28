import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/services/login_service.dart';

class LoginController extends GetxController {
  // Gunakan Get.find() karena service didaftarkan di LoginBinding
  final LoginService _service = Get.find<LoginService>();

  var isLoading = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan Password harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Error',
        'Format email tidak valid',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _service.login(email, password);

      // Pastikan response tidak null DAN ada access token
      if (response != null && response['accessToken'] != null) {
        // Ambil 'name' dari 'user' object, berikan default jika null
        String userName =
            response['user']?['name'] ?? 'Pengguna'; // Default 'Pengguna'

        Get.snackbar(
          'Sukses',
          'Login berhasil!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Kirim 'userName' (yang berisi 'name' dari API) sebagai argumen
        Get.offAllNamed('/home', arguments: userName);
      } else {
        // Ambil pesan error dari API jika ada, atau gunakan pesan default
        String errorMessage =
            response?['message'] ?? 'Email atau password salah.';
        Get.snackbar(
          'Gagal',
          errorMessage,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Terjadi kesalahan tidak diketahui',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
