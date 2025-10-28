import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SIMARU Unigal"),
        // Style AppBar akan mengikuti tema di main.dart
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              controller.logout();
            },
          ),
        ],
        automaticallyImplyLeading: false, // Sembunyikan tombol back default
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: controller.unigalColor),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchHomeData(); // Panggil fetch data saat refresh
            controller
                .fetchArguments(); // Panggil lagi untuk memastikan nama user terupdate jika ada perubahan dari sumber lain
          },
          color: controller.unigalColor,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Selalu bisa di-scroll untuk refresh
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 24),
                Text(
                  "Menu Utama",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: controller.unigalColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMenuGrid(),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Widget Kartu Selamat Datang
  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: controller.unigalColor.withAlpha(30),
        ),
        child: Row(
          children: [
            Icon(Icons.account_circle, size: 50, color: controller.unigalColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selamat Datang,",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  Obx(
                    // Pastikan nama update jika state berubah
                    () => Text(
                      controller
                          .userName
                          .value, // Ambil nama dari state controller
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: controller.unigalColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Grid Menu
  Widget _buildMenuGrid() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.meeting_room,
        'label': "Pinjam Ruangan",
        'route': '/pinjam-ruangan',
      },
      {
        'icon': Icons.calendar_today,
        'label': "Jadwal Ruangan",
        'route': '/jadwal-ruangan',
      },
      {
        'icon': Icons.history,
        'label': "Riwayat Peminjaman",
        'route': '/riwayat',
      },
      {
        'icon': Icons.person_outline,
        'label': "Profil Saya",
        'route': '/profil',
      },
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: menuItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(
          icon: item['icon'],
          label: item['label'],
          onTap: () {
            // Get.toNamed(item['route']); // Aktifkan jika rute sudah ada
            Get.snackbar(
              "Info",
              "Fitur '${item['label']}' segera hadir!",
              snackPosition: SnackPosition.TOP, // Tampilkan di atas
              backgroundColor: Colors.blueAccent, // Warna latar
              colorText: Colors.white, // Warna teks
              margin: const EdgeInsets.all(10), // Margin
              borderRadius: 8, // Radius border
            );
          },
        );
      },
    );
  }

  // Widget Item Menu Tunggal
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 45, color: controller.unigalColor),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
