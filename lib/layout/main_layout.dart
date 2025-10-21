// lib/layout/main_layout.dart
import 'package:flutter/material.dart';
import 'package:swd_mobie_flutter/features/booking/presentation/booking_page.dart';
import 'package:swd_mobie_flutter/features/home/presentation/home_page.dart';
import 'package:swd_mobie_flutter/features/settings/presentation/settings_page.dart';
import 'package:swd_mobie_flutter/features/studio/presentation/studio_page.dart';
// 1. Import các trang mới

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // 2. Cập nhật danh sách _pages
  final List<Widget> _pages = const [
    HomePage(),
    BookingPage(), // Thay thế SearchPage
    StudioPage(), // Thay thế ProfilePage
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Lấy màu từ theme (nếu bạn đã định nghĩa)
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color unselectedColor = Colors.grey;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Đảm bảo 4 item luôn hiển thị
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // 3. Cập nhật màu sắc cho giống UI
        selectedItemColor: primaryColor, // Màu khi được chọn
        unselectedItemColor: unselectedColor, // Màu khi không được chọn
        showSelectedLabels: true, // Hiển thị label khi chọn
        showUnselectedLabels: true, // Luôn hiển thị label
        selectedFontSize: 12, // Cỡ chữ
        unselectedFontSize: 12,

        // 4. Cập nhật items cho đúng UI
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), // Icon Trang chủ
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded), // Icon Đặt lịch
            label: "Đặt lịch",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic_external_on_rounded), // Icon Studio
            label: "Studio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded), // Icon Cài đặt
            label: "Cài đặt",
          ),
        ],
      ),
    );
  }
}
