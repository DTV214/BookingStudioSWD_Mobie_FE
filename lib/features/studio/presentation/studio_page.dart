// lib/features/studio/presentation/studio_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Provider và State
import '../presentation/providers/studio_provider.dart';

// Import các widget con
import 'widgets/studio_overview.dart';
import 'widgets/filter_tabs.dart';
import 'widgets/studio_card.dart';

// 1. Chuyển thành StatefulWidget
class StudioPage extends StatefulWidget {
  const StudioPage({super.key});

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  // 2. Gọi hàm fetchStudios() khi trang được xây dựng lần đầu
  @override
  void initState() {
    super.initState();
    // Dùng context.read hoặc Provider.of... (listen: false) trong initState
    // để yêu cầu Provider bắt đầu tải dữ liệu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudioProvider>().fetchStudios();
    });
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
          "Quản lý Studio",
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
      // 3. Dùng ListView cho phần body chính
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Tổng quan (widget này không đổi)
          StudioOverview(),
          SizedBox(height: 20),

          // 2. Filter tabs (widget này không đổi)
          FilterTabs(),
          SizedBox(height: 20),

          // 3. Xử lý phần danh sách studio (đây là phần chính)
          _buildStudioList(),
        ],
      ),
    );
  }

  // 4. Tách logic build danh sách ra widget riêng
  Widget _buildStudioList() {
    // 5. Lắng nghe thay đổi từ StudioProvider
    // Dùng context.watch<T>() hoặc Provider.of<T>(context)
    final provider = context.watch<StudioProvider>();

    // 6. Xử lý các trạng thái
    switch (provider.state) {
      case StudioState.loading:
      case StudioState.initial: // Coi trạng thái ban đầu cũng là loading
        return Center(
          child: CircularProgressIndicator(color: Color(0xFF6A40D3)),
        );

      case StudioState.error:
        return Center(
          child: Text(
            "Lỗi tải dữ liệu: ${provider.errorMessage}",
            style: TextStyle(color: Colors.red),
          ),
        );

      case StudioState.loaded:
        // Nếu không có studio nào
        if (provider.studios.isEmpty) {
          return Center(child: Text("Không tìm thấy studio nào."));
        }

        // Nếu có dữ liệu, hiển thị danh sách
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tất cả Studio (${provider.studios.length})",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Dùng ListView.builder để xây dựng danh sách
            // Nhưng vì đang lồng trong ListView cha, ta dùng Column + map
            Column(
              children: provider.studios.map((studio) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: StudioCard(studio: studio), // Dùng dữ liệu thật
                );
              }).toList(),
            ),
          ],
        );
    }
  }
}
