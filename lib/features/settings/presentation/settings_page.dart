// lib/features/settings/presentation/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Sửa lại đường dẫn import nếu bạn đặt tên feature là 'account'
import 'package:swd_mobie_flutter/features/account/presentation/provider/profile_provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_item.dart';
import 'widgets/settings_toggle.dart';
import 'widgets/stats_footer.dart';
// Import các file cần thiết cho việc điều hướng
import 'package:swd_mobie_flutter/features/account/presentation/pages/edit_profile_page.dart';
import 'package:swd_mobie_flutter/features/account/domain/entities/account_profile.dart';

// 1. CHUYỂN THÀNH STATEFULWIDGET
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // 2. TỰ ĐỘNG TẢI PROFILE KHI MỞ TRANG
    Future.microtask(() {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  // 3. TẠO HÀM ĐIỀU HƯỚNG TÁI SỬ DỤNG
  void _navigateToEditPage(Profile? profile) {
    // Chỉ điều hướng nếu profile không null
    if (profile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          // Gửi profile hiện tại sang trang EditProfilePage
          builder: (_) => EditProfilePage(profile: profile),
        ),
      );
    }
  }

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
      // 4. DÙNG CONSUMER ĐỂ LẮNG NGHE PROVIDER
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          final profile = provider.profile;
          final isLoading = provider.state == ProfileState.loading;

          // ⭐ XỬ LÝ TRẠNG THÁI TẢI LẦN ĐẦU
          if (isLoading && profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // ⭐ XỬ LÝ TRẠNG THÁI LỖI LẦN ĐẦU
          if (provider.state == ProfileState.error && profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Lỗi tải thông tin: ${provider.errorMessage}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // --- Nếu có dữ liệu ---
          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. Header (đã kết nối)
                ProfileHeader(
                  name:
                      profile?.fullName ??
                      (isLoading ? "Đang tải..." : "Chưa có tên"),
                  email:
                      profile?.email ?? (isLoading ? "..." : "Chưa có email"),
                  id: profile?.id ?? (isLoading ? "..." : "NV001"),
                  avatarUrl: profile?.avatarUrl ?? "NV",
                  // ⭐ SỬA LỖI 3: THÊM HÀM ĐIỀU HƯỚNG
                  onEditPressed: () => _navigateToEditPage(profile),
                ),

                // 2. Nhóm Tài khoản (đã kết nối)
                SettingsSection(
                  title: "Tài khoản",
                  children: [
                    SettingsItem(
                      icon: Icons.person_outline,
                      title: "Thông tin cá nhân",
                      subtitle: profile?.fullName ?? "",
                      // ⭐ SỬA LỖI 2: THÊM HÀM ĐIỀU HƯỚNG
                      onTap: () => _navigateToEditPage(profile),
                    ),
                    SettingsItem(
                      icon: Icons.work_outline,
                      title: "Chức vụ",
                      // ⭐ SỬA LỖI 1: LẤY DỮ LIỆU ĐỘNG
                      subtitle: profile?.accountRole ?? "...",
                      onTap: () {}, // Không làm gì
                    ),
                    SettingsItem(
                      icon: Icons.payment_outlined,
                      title: "Phương thức thanh toán",
                      onTap: () {},
                    ),
                  ],
                ),

                // ... (Các phần còn lại giữ nguyên)
                SettingsSection(
                  title: "Thông báo",
                  children: [
                    SettingsToggle(
                      icon: Icons.notifications_active_outlined,
                      title: "Thông báo booking mới",
                      value: true,
                      onChanged: (val) {},
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
                StatsFooter(),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
