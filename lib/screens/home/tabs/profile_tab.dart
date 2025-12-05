import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/controllers/home_controller.dart';
import 'package:simaru/models/user_profile.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
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
}
