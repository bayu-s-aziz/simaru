import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/services/register_service.dart'; // Pastikan path import benar

class RegisterController extends GetxController {
  final RegisterService _service = Get.find<RegisterService>();

  var isLoading = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final passwordConfirmation = passwordConfirmationController.text.trim();

    // Validasi input
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        passwordConfirmation.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
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
    if (password != passwordConfirmation) {
      Get.snackbar(
        'Error',
        'Password dan konfirmasi password tidak cocok',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (password.length < 8) {
      Get.snackbar(
        'Error',
        'Password minimal harus 8 karakter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _service.register(
        name,
        email,
        password,
        passwordConfirmation,
      );

      // --- PERBAIKAN KONDISI SUKSES ---
      // Asumsikan jika response TIDAK null, berarti registrasi sukses (karena service sudah cek status code 200/201)
      if (response != null) {
        Get.snackbar(
          'Sukses', // <-- Judul diubah
          'Registrasi berhasil! Silakan login.',
          backgroundColor: Colors.green, // <-- Warna hijau
          colorText: Colors.white,
        );
        Get.offNamed('/login');
      } else {
        // Jika response null (karena status code bukan 200/201 atau ada masalah lain di service)
        // Anda bisa mencoba mendapatkan detail error dari response service jika dimungkinkan,
        // tapi untuk sekarang kita tampilkan pesan umum.
        Get.snackbar(
          'Gagal',
          'Registrasi gagal. Server mungkin mengembalikan error atau email sudah terdaftar.', // Pesan error lebih informatif
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      // --- AKHIR PERBAIKAN ---
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.onClose();
  }
}
