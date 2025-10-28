import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/controllers/register_controller.dart'; // Import controller yang benar

// Ganti nama class menjadi RegisterScreen
class RegisterScreen extends GetView<RegisterController> {
  // Ganti generic type
  const RegisterScreen({super.key});
  final Color unigalColor = const Color(0xFF592974);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tambahkan AppBar
      appBar: AppBar(
        title: const Text('Register Akun Baru'),
        backgroundColor: unigalColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          // Tombol kembali
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(), // Fungsi untuk kembali
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Register", // Ganti teks judul
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: unigalColor,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Field Nama
                  TextField(
                    controller:
                        controller.nameController, // Gunakan nameController
                    decoration: InputDecoration(
                      labelText: "Nama Lengkap", // Label yang lebih sesuai
                      prefixIcon: const Icon(
                        Icons.person_outline,
                      ), // Ganti ikon jika perlu
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 20),

                  // Field Email
                  TextField(
                    controller: controller.emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // Field Password
                  TextField(
                    controller: controller.passwordController,
                    obscureText: true, // Sembunyikan teks password
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // Tambahkan ikon untuk show/hide password jika diinginkan
                    ),
                  ),
                  const SizedBox(height: 20), // Kurangi jarak sedikit
                  // Field Konfirmasi Password
                  TextField(
                    controller: controller.passwordConfirmationController,
                    obscureText: true, // Sembunyikan teks password
                    decoration: InputDecoration(
                      labelText:
                          "Konfirmasi Password", // Label yang lebih sesuai
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Tombol Register
                  Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: unigalColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // Nonaktifkan tombol saat loading
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.register(),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Register", // Ganti teks tombol
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Opsi untuk kembali ke Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun? "),
                      TextButton(
                        onPressed: () {
                          Get.back(); // Kembali ke halaman sebelumnya (Login)
                        },
                        child: Text(
                          'Login di sini',
                          style: TextStyle(
                            color: unigalColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
