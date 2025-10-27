import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // MỚI
import 'package:swd_mobie_flutter/features/account/presentation/provider/profile_provider.dart';
import 'package:swd_mobie_flutter/features/settings/presentation/settings_page.dart';

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

    // MỚI: Bọc Scaffold trong Consumer để lấy dữ liệu profile
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        // Lấy tên của profile (nếu đã tải)
        final String staffName =
            profileProvider.profile?.fullName ?? "Nhân viên";

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: primaryColor,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Studio Manager",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Xin chào, $staffName", // MỚI: Cập nhật tên động
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
                onPressed: () {
                  // MỚI: Điều hướng sang trang Settings
                  // Trang Settings sẽ tự động lo việc tải profile
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
          // 2. Body (giữ nguyên)
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
      },
    );
  }
}
