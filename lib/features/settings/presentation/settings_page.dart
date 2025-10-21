// lib/features/settings/presentation/settings_page.dart
import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_item.dart';
import 'widgets/settings_toggle.dart';
import 'widgets/stats_footer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
        child: Column(
          children: [
            // 1. Header
            ProfileHeader(
              name: "Nguyễn Văn A",
              email: "nhanvien@studio.com",
              id: "NV001",
              avatarUrl: "NV", // Hoặc link ảnh
            ),

            // 2. Nhóm Tài khoản
            SettingsSection(
              title: "Tài khoản",
              children: [
                SettingsItem(
                  icon: Icons.person_outline,
                  title: "Thông tin cá nhân",
                  subtitle: "Nguyễn Văn A",
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.work_outline,
                  title: "Chức vụ",
                  subtitle: "Nhân viên quản lý",
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.payment_outlined,
                  title: "Phương thức thanh toán",
                  onTap: () {},
                ),
              ],
            ),

            // 3. Nhóm Thông báo
            SettingsSection(
              title: "Thông báo",
              children: [
                SettingsToggle(
                  icon: Icons.notifications_active_outlined,
                  title: "Thông báo booking mới",
                  value: true, // Giá trị mặc định
                  onChanged: (val) {
                    // TODO: Xử lý bật/tắt
                  },
                ),
                SettingsToggle(
                  icon: Icons.message_outlined,
                  title: "Thông báo tin nhắn",
                  value: false,
                  onChanged: (val) {},
                ),
                SettingsToggle(
                  icon: Icons.discount_outlined,
                  title: "Thông báo khuyến mãi",
                  value: true,
                  onChanged: (val) {},
                ),
              ],
            ),

            // 4. Nhóm Cài đặt chung
            SettingsSection(
              title: "Cài đặt chung",
              children: [
                SettingsToggle(
                  icon: Icons.dark_mode_outlined,
                  title: "Chế độ tối",
                  value: false,
                  onChanged: (val) {},
                ),
                SettingsItem(
                  icon: Icons.language_outlined,
                  title: "Ngôn ngữ",
                  subtitle: "Tiếng Việt",
                  onTap: () {},
                ),
              ],
            ),

            // 5. Nhóm Hỗ trợ
            SettingsSection(
              title: "Hỗ trợ",
              children: [
                SettingsItem(
                  icon: Icons.help_outline,
                  title: "Trung tâm trợ giúp",
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.description_outlined,
                  title: "Điều khoản dịch vụ",
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: "Chính sách bảo mật",
                  onTap: () {},
                ),
              ],
            ),

            // 6. Thống kê
            StatsFooter(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
