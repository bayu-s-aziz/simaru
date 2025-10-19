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
        backgroundColor: controller.unigalColor, // Ambil warna dari controller
        foregroundColor: Colors.white, // Warna ikon dan teks di AppBar
        actions: [
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout", // Teks saat ditahan lama
            onPressed: () {
              controller.logout(); // Panggil fungsi logout dari controller
            },
          ),
        ],
        // Menonaktifkan tombol kembali otomatis jika halaman ini adalah tujuan utama setelah login
        automaticallyImplyLeading: false,
      ),
      // Gunakan Obx untuk bagian UI yang perlu bereaksi terhadap perubahan state isLoading
      body: Obx(() {
        // Tampilkan loading indicator jika isLoading true
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: controller.unigalColor),
          );
        }
        // Tampilkan konten utama jika tidak loading
        return RefreshIndicator(
          // Tambahkan pull-to-refresh
          onRefresh: () async {
            controller
                .fetchHomeData(); // Panggil fungsi fetch data saat refresh
          },
          color: controller.unigalColor,
          child: SingleChildScrollView(
            // Agar bisa di-scroll jika konten panjang
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Kartu Selamat Datang
                _buildWelcomeCard(),
                const SizedBox(height: 24), // Jarak antar elemen
                // 2. Judul Menu
                Text(
                  "Menu Utama",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: controller.unigalColor,
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Grid Menu
                _buildMenuGrid(),

                // Tambahkan widget lain di sini jika perlu
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- Helper Widgets ---

  // Widget untuk membuat Kartu Selamat Datang
  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4, // Efek bayangan kartu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Sudut kartu
      child: Container(
        padding: const EdgeInsets.all(20),
        // Dekorasi latar belakang sedikit transparan
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: controller.unigalColor.withAlpha(30),
        ),
        child: Row(
          children: [
            // Ikon profil
            Icon(Icons.account_circle, size: 50, color: controller.unigalColor),
            const SizedBox(width: 16),
            // Teks sambutan dan nama pengguna
            Expanded(
              // Agar teks bisa mengisi sisa ruang
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selamat Datang,",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  // Gunakan Obx lagi di sini agar nama update jika berubah nanti
                  Obx(
                    () => Text(
                      controller
                          .userName
                          .value, // Ambil nama dari state controller
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: controller.unigalColor,
                      ),
                      overflow: TextOverflow
                          .ellipsis, // Atasi jika nama terlalu panjang
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

  // Widget untuk membuat Grid Menu
  Widget _buildMenuGrid() {
    // Daftar item menu
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
      // Konfigurasi Grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Jumlah kolom
        crossAxisSpacing: 16, // Jarak horizontal antar item
        mainAxisSpacing: 16, // Jarak vertikal antar item
        childAspectRatio: 1.1, // Rasio lebar:tinggi item (sesuaikan agar pas)
      ),
      itemCount: menuItems.length, // Jumlah item menu
      shrinkWrap: true, // Agar GridView menyesuaikan tingginya dengan konten
      physics:
          const NeverScrollableScrollPhysics(), // Nonaktifkan scroll internal GridView
      // Builder untuk setiap item menu
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(
          icon: item['icon'],
          label: item['label'],
          onTap: () {
            // Cek jika rute sudah didefinisikan atau belum
            // Get.toNamed(item['route']); // Aktifkan ini jika rute sudah ada
            Get.snackbar(
              "Info",
              "Fitur '${item['label']}' segera hadir!",
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );
      },
    );
  }

  // Widget untuk membuat satu item menu dalam Grid
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      // Membuat area bisa diklik dengan efek ripple
      onTap: onTap,
      borderRadius: BorderRadius.circular(12), // Sesuaikan radius dengan Card
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          // Beri padding di dalam Card
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Pusatkan konten vertikal
            crossAxisAlignment:
                CrossAxisAlignment.center, // Pusatkan konten horizontal
            children: [
              Icon(
                icon,
                size: 45,
                color: controller.unigalColor,
              ), // Ukuran ikon
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center, // Teks rata tengah
                style: const TextStyle(
                  fontSize: 15, // Ukuran font label
                  fontWeight: FontWeight.w600, // Ketebalan font
                  color: Colors.black87,
                ),
                maxLines: 2, // Maksimal 2 baris jika label panjang
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
