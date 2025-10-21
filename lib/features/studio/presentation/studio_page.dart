// lib/features/studio/presentation/studio_page.dart
import 'package:flutter/material.dart';
import 'widgets/studio_overview.dart';
import 'widgets/filter_tabs.dart';
import 'widgets/studio_card.dart';

class StudioPage extends StatelessWidget {
  const StudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF6A40D3);
    final Color backgroundColor = Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          "Studio Manager",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tổng quan
            StudioOverview(),
            SizedBox(height: 20),

            // 2. Filter tabs
            FilterTabs(),
            SizedBox(height: 20),

            // 3. Danh sách studio
            StudioCard(
              imageUrl:
                  "https://via.placeholder.com/300x200", // Thay bằng ảnh thật
              status: StudioStatus.available,
              studioName: "Studio Music Pro",
              price: "250.000đ/giờ",
              studioType: "Music Studio",
              booking: "8/12",
              capacity: "1-3 người",
              revenue: "2.000.000đ",
              usage: 67, // Tỷ lệ 67%
              equipments: [
                "Microphone",
                "Mixer",
                "Headphones",
                "Acoustic Treatment",
              ],
            ),
            SizedBox(height: 16),
            StudioCard(
              imageUrl:
                  "https://via.placeholder.com/300x200", // Thay bằng ảnh thật
              status: StudioStatus.inUse,
              studioName: "Studio Photo 1",
              price: "200.000đ/giờ",
              studioType: "Photo Studio",
              booking: "5/8",
              capacity: "1-5 người",
              revenue: "1.000.000đ",
              usage: 63, // Tỷ lệ 63%
              equipments: ["Professional Camera", "Lighting Kit", "Backdrop"],
            ),
            SizedBox(height: 16),
            StudioCard(
              imageUrl:
                  "https://via.placeholder.com/300x200", // Thay bằng ảnh thật
              status: StudioStatus.maintenance,
              studioName: "Studio Photo 2",
              price: "200.000đ/giờ",
              studioType: "Photo Studio",
              booking: "0/8",
              capacity: "1-5 người",
              revenue: "0đ",
              usage: 0, // Tỷ lệ 0%
              equipments: ["Lighting Kit", "Backdrop"],
            ),
          ],
        ),
      ),
    );
  }
}
