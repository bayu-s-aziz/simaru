import 'package:file_picker/file_picker.dart';
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
      final rooms = controller.filteredRooms;

      if (isLoading && controller.rooms.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final hasRooms = rooms.isNotEmpty;

      return RefreshIndicator(
        onRefresh: () => controller.loadRooms(forceRefresh: true),
        color: controller.unigalColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          shrinkWrap: true,
          primary: false,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: hasRooms ? rooms.length + 1 : 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchAndAddBar(context),
                  const SizedBox(height: 12),
                ],
              );
            }

            if (!hasRooms && index == 1) {
              final message =
                  errorMessage ??
                  (controller.rooms.isEmpty
                      ? 'Belum ada data ruangan yang tersedia.'
                      : 'Tidak ada ruangan yang cocok dengan pencarian.');
              return _buildRoomsMessage(
                icon: Icons.meeting_room_outlined,
                message: message,
              );
            }

            final room = rooms[index - 1];
            return _buildRoomCard(context, room);
          },
        ),
      );
    });
  }

  Widget _buildSearchAndAddBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.updateSearchQuery,
            decoration: InputDecoration(
              hintText: 'Cari ruangan, fakultas, atau status...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.unigalColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _showRoomForm(context),
          icon: const Icon(Icons.add),
          label: const Text('Tambah'),
        ),
      ],
    );
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

  Widget _buildRoomCard(BuildContext context, Room room) {
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
                  const SizedBox(height: 8),
                  Text(
                    room.displayStatus,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: controller.unigalColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _showRoomForm(context, room: room),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                      TextButton.icon(
                        onPressed: () => _confirmDelete(context, room),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Hapus'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
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

  Future<void> _showRoomForm(BuildContext context, {Room? room}) async {
    final nameCtrl = TextEditingController(text: room?.name ?? '');
    final facultyCtrl = TextEditingController(text: room?.facultyName ?? '');
    final capacityCtrl = TextEditingController(
      text: room?.capacity?.toString() ?? '',
    );
    final statusCtrl = TextEditingController(text: room?.status ?? '');
    PlatformFile? selectedPhoto;
    final hasExistingPhoto = room?.photo?.trim().isNotEmpty ?? false;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(room == null ? 'Tambah Ruangan' : 'Edit Ruangan'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Ruangan',
                      ),
                    ),
                    TextField(
                      controller: facultyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Fakultas',
                      ),
                    ),
                    TextField(
                      controller: capacityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Kapasitas'),
                    ),
                    TextField(
                      controller: statusCtrl,
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Foto',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedPhoto?.name ??
                                (hasExistingPhoto
                                    ? 'Foto saat ini akan dipertahankan'
                                    : 'Belum ada foto'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                              withData: true,
                            );

                            if (result != null && result.files.isNotEmpty) {
                              setState(() {
                                selectedPhoto = result.files.first;
                              });
                            }
                          },
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Pilih'),
                        ),
                      ],
                    ),
                    if (selectedPhoto != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => setState(() => selectedPhoto = null),
                          child: const Text('Hapus pilihan'),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Nama ruangan wajib diisi.',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    final capacity = int.tryParse(capacityCtrl.text.trim());
                    final facultyName = facultyCtrl.text.trim().isEmpty
                        ? null
                        : facultyCtrl.text.trim();
                    final status = statusCtrl.text.trim().isEmpty
                        ? null
                        : statusCtrl.text.trim();

                    if (room == null) {
                      controller.addRoom(
                        name: name,
                        facultyName: facultyName,
                        capacity: capacity,
                        status: status,
                        photoFile: selectedPhoto,
                      );
                    } else {
                      controller.editRoom(
                        room,
                        name: name,
                        facultyName: facultyName,
                        capacity: capacity,
                        status: status,
                        photoFile: selectedPhoto,
                      );
                    }
                    Get.back();
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    facultyCtrl.dispose();
    capacityCtrl.dispose();
    statusCtrl.dispose();
  }

  void _confirmDelete(BuildContext context, Room room) {
    Get.defaultDialog(
      title: 'Hapus Ruangan',
      middleText: 'Anda yakin ingin menghapus "${room.displayName}"?',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: controller.unigalColor,
      onConfirm: () {
        Get.back();
        controller.removeRoom(room);
      },
    );
  }
}
