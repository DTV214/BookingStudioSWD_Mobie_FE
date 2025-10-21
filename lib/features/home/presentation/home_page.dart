// lib/features/home/presentation/home_page.dart
import 'package:flutter/material.dart';

// 1. Import các widget bạn vừa tạo
import 'widgets/stats_grid.dart';
import 'widgets/promotion_banner.dart';
import 'widgets/quick_actions.dart';
import 'widgets/today_schedule.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF6A40D3);
    final Color backgroundColor = Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Studio Manager",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Xin chào, Nhân viên",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
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
      // 2. Body bây giờ chỉ việc gọi các widget
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Lưới thống kê
            StatsGrid(),

            SizedBox(height: 20),

            // 2. Banner khuyến mãi
            PromotionBanner(),

            SizedBox(height: 20),

            // 3. Thao tác nhanh
            QuickActions(),

            SizedBox(height: 20),

            // 4. Lịch đặt hôm nay
            TodaySchedule(),
          ],
        ),
      ),
    );
  }
}
