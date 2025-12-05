import 'package:flutter/material.dart';
import 'package:simaru/controllers/home_controller.dart';

class BookingTab extends StatelessWidget {
  const BookingTab({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
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
              'Booking',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: controller.unigalColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Fitur ini sedang dalam pengembangan',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
