import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/controllers/home_controller.dart';
import 'package:simaru/models/room.dart';
import 'package:simaru/models/user_profile.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: controller.unigalColor),
          );
        }

        return SafeArea(
          bottom: false, // Agar tidak ada padding di bawah
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ), // Hapus padding bottom
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ), // Hanya rounded di atas
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ), // Hanya rounded di atas
                child: CustomScrollView(
                  slivers: [
                    // AppBar yang ikut scroll
                    SliverAppBar(
                      floating: false,
                      pinned: false,
                      backgroundColor: Colors.transparent,
                      title: Obx(
                        () => Text(
                          _getAppBarTitle(controller.selectedTabIndex.value),
                          style: TextStyle(
                            color: controller.unigalColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      automaticallyImplyLeading: false,
                    ),
                    // Konten body
                    SliverToBoxAdapter(
                      child: _buildBodyContent(
                        controller.selectedTabIndex.value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedTabIndex.value,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: controller.unigalColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              label: "Pinjam",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room_outlined),
              label: "Ruangan",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk mendapatkan title AppBar sesuai tab
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return "SIMARU Unigal";
      case 1:
        return "Pinjam Ruangan";
      case 2:
        return "Daftar Ruangan";
      case 3:
        return "Profil Saya";
      default:
        return "SIMARU Unigal";
    }
  }

  // Widget Body sesuai tab yang dipilih
  Widget _buildBodyContent(int index) {
    switch (index) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildPlaceholderTab("Pinjam Ruangan");
      case 2:
        return _buildRoomsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  // Tab Beranda (konten utama)
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        controller.fetchHomeData();
        controller.fetchArguments();
      },
      color: controller.unigalColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
  }

  // Placeholder untuk tab lain
  Widget _buildPlaceholderTab(String title) {
    return SizedBox(
      height: 500,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: controller.unigalColor.withAlpha(150),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: controller.unigalColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Fitur ini sedang dalam pengembangan",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
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
                    () => Text(
                      controller.userName.value.isNotEmpty
                          ? controller.userName.value
                          : 'Pengguna',
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
        'icon': Icons.assignment_outlined,
        'label': "Pinjam Ruangan",
        'tabIndex': 1,
      },
      {'icon': Icons.list_alt, 'label': "Daftar Ruangan", 'tabIndex': 2},
      {'icon': Icons.person_outline, 'label': "Profil Saya", 'tabIndex': 3},
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
            controller.changeTabIndex(item['tabIndex']);
          },
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Obx(() {
      final UserProfile? profile = controller.userProfile.value;
      final displayName = profile?.displayName ?? controller.userName.value;
      final details = <Widget>[
        _buildInfoRow(
          icon: Icons.badge_outlined,
          label: 'Nama Lengkap',
          value: displayName,
        ),
      ];

      if (profile?.email != null && profile!.email!.isNotEmpty) {
        details.add(
          _buildInfoRow(
            icon: Icons.mail_outline,
            label: 'Email',
            value: profile.email!,
          ),
        );
      }

      if (profile?.phone != null && profile!.phone!.isNotEmpty) {
        details.add(
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'No. Telepon',
            value: profile.phone!,
          ),
        );
      }

      if (profile?.role != null && profile!.role!.isNotEmpty) {
        details.add(
          _buildInfoRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Peran',
            value: profile.role!,
          ),
        );
      }

      if (details.length == 1) {
        details.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'Informasi profil tambahan belum tersedia.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: controller.unigalColor.withAlpha(40),
                      child: Icon(
                        Icons.person_outline,
                        color: controller.unigalColor,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profil Pengguna',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: controller.unigalColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Detail Akun',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: controller.unigalColor,
              ),
            ),
            const SizedBox(height: 12),
            ...details,
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.unigalColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: controller.logout,
              icon: const Icon(Icons.logout),
              label: const Text(
                'Keluar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRoomsTab() {
    return Obx(() {
      final isLoading = controller.roomsLoading.value;
      final errorMessage = controller.roomsError.value;
      final rooms = controller.rooms;

      if (isLoading && rooms.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadRooms(forceRefresh: true),
        color: controller.unigalColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: rooms.isEmpty ? 1 : rooms.length,
          itemBuilder: (context, index) {
            if (rooms.isEmpty) {
              if (errorMessage != null) {
                return _buildRoomsMessage(
                  icon: Icons.error_outline,
                  message:
                      'Gagal memuat data ruangan. Coba tarik ke bawah untuk menyegarkan.',
                  detail: errorMessage,
                );
              }
              return _buildRoomsMessage(
                icon: Icons.meeting_room_outlined,
                message: 'Belum ada data ruangan yang tersedia.',
              );
            }

            final room = rooms[index];
            return _buildRoomCard(room);
          },
        ),
      );
    });
  }

  Widget _buildRoomsMessage({
    required IconData icon,
    required String message,
    String? detail,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: controller.unigalColor.withAlpha(150)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRoomThumbnail(room),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.displayFaculty,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 18,
                        color: controller.unigalColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        room.capacity != null
                            ? 'Kapasitas: ${room.capacity}'
                            : 'Kapasitas tidak tersedia',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(room.status).withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        room.displayStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _statusColor(room.status),
                        ),
                      ),
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

  Widget _buildRoomThumbnail(Room room) {
    if (room.hasPhoto) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          room.photo!,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildRoomPlaceholderIcon();
          },
        ),
      );
    }

    return _buildRoomPlaceholderIcon();
  }

  Widget _buildRoomPlaceholderIcon() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: controller.unigalColor.withAlpha(30),
      ),
      child: Icon(
        Icons.meeting_room_outlined,
        size: 40,
        color: controller.unigalColor,
      ),
    );
  }

  Color _statusColor(String? status) {
    final normalized = status?.toLowerCase().trim();
    switch (normalized) {
      case 'tersedia':
      case 'available':
        return Colors.green;
      case 'tidak tersedia':
      case 'booked':
      case 'penuh':
        return Colors.red;
      case 'perbaikan':
      case 'maintenance':
        return Colors.orange;
      default:
        return controller.unigalColor;
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: controller.unigalColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
