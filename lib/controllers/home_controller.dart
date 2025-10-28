import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // State reaktif untuk nama pengguna
  var userName = 'Pengguna'.obs; // Nilai default yang lebih umum
  var isLoading = false.obs;

  final unigalColor = const Color(0xFF592974);

  @override
  void onInit() {
    super.onInit();
    fetchArguments(); // Panggil fungsi untuk mengambil argumen
    // Anda bisa memanggil fungsi untuk memuat data dashboard di sini jika perlu
    // fetchHomeData();
  }

  // Fungsi terpisah untuk mengambil dan memvalidasi argumen
  void fetchArguments() {
    final arguments = Get.arguments;
    print("HomeController received arguments: $arguments"); // Untuk debugging
    if (arguments != null && arguments is String && arguments.isNotEmpty) {
      userName.value =
          arguments; // Update state userName dengan nama dari login
      print(
        "HomeController updated userName: ${userName.value}",
      ); // Untuk debugging
    } else {
      // Jika tidak ada argumen (misal saat hot reload di home), biarkan default
      print(
        "HomeController: No valid username argument. Using default: ${userName.value}",
      );
    }
  }

  // Contoh fungsi untuk memuat data dari API (jika diperlukan)
  void fetchHomeData() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1)); // Simulasi delay API
      // Logika fetch data lain...
      print("Fetching home data...");
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      confirmTextColor: Colors.white, // Warna teks tombol Confirm
      buttonColor: unigalColor, // Warna latar tombol Confirm
      cancelTextColor: unigalColor, // Warna teks tombol Cancel
      onConfirm: () {
        // Kembali ke halaman login dan hapus semua halaman sebelumnya dari stack
        Get.offAllNamed('/login');
      },
    );
  }
}
