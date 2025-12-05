import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simaru/controllers/home_controller.dart';
import 'package:simaru/models/room.dart';

class RoomsTab extends StatelessWidget {
  const RoomsTab({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
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
          shrinkWrap: true,
          primary: false,
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
}
