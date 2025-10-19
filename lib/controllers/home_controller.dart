import 'package:flutter/material.dart';
import 'package:get/get.dart';
// LoginScreen tidak perlu diimpor lagi jika menggunakan named route
// import 'package:simaru/screens/login_screen.dart';

class HomeController extends GetxController {
  // State reaktif untuk nama pengguna
  var userName = 'Mahasiswa Unigal'.obs; // Nilai default
  // State reaktif untuk loading
  var isLoading = false.obs;

  // Warna utama (bisa dipindah ke file tema/konstanta nanti)
  final unigalColor = const Color(0xFF592974);

  // onInit dipanggil saat controller pertama kali dibuat
  @override
  void onInit() {
    super.onInit();
    // Terima argumen (nama pengguna) yang dikirim dari halaman login
    final arguments = Get.arguments;
    if (arguments != null && arguments is String) {
      userName.value = arguments; // Update state userName
    }
    // Anda bisa memanggil fungsi untuk memuat data dashboard di sini jika perlu
    // fetchHomeData();
  }

  // Contoh fungsi untuk memuat data dari API (jika diperlukan)
  void fetchHomeData() async {
    try {
      isLoading.value = true;
      // Simulasi pemanggilan API
      await Future.delayed(const Duration(seconds: 1));
      // Contoh update data lain jika ada
      // Misal: var roomCount = await apiService.getRoomCount();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk logout
  void logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Apakah Anda yakin ingin keluar?",
      textConfirm: "Ya",
      textCancel: "Tidak",
      confirmTextColor: Colors.white, // Agar kontras dengan buttonColor
      buttonColor: unigalColor,
      cancelTextColor: unigalColor,
      onConfirm: () {
        // Kembali ke halaman login (/login) menggunakan nama rute
        // dan hapus semua halaman sebelumnya (offAllNamed).
        Get.offAllNamed('/login');
      },
    );
  }
}
