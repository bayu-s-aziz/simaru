import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/controllers/home_controller.dart';
import 'package:simaru/screens/home/tabs/booking_tab.dart';
import 'package:simaru/screens/home/tabs/profile_tab.dart';
import 'package:simaru/screens/home/tabs/rooms_tab.dart';
import 'package:simaru/screens/home/widgets/bottom_navigation.dart';

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
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
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
                ),
                child: CustomScrollView(
                  slivers: [
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
      bottomNavigationBar: HomeBottomNavigation(controller: controller),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return "SIMARU Unigal";
      case 1:
        return "Booking";
      case 2:
        return "Daftar Ruangan";
      case 3:
        return "Profil Saya";
      default:
        return "SIMARU Unigal";
    }
  }

  Widget _buildBodyContent(int index) {
    switch (index) {
      case 0:
        return _buildHomeTab();
      case 1:
        return BookingTab(controller: controller);
      case 2:
        return RoomsTab(controller: controller);
      case 3:
        return ProfileTab(controller: controller);
      default:
        return _buildHomeTab();
    }
  }

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

  Widget _buildMenuGrid() {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.assignment_outlined, 'label': "Booking", 'tabIndex': 1},
      {'icon': Icons.list_alt, 'label': "Rooms", 'tabIndex': 2},
      {'icon': Icons.person_outline, 'label': "Profile", 'tabIndex': 3},
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
