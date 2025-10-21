// lib/features/booking/presentation/booking_page.dart
import 'package:flutter/material.dart';
import 'widgets/search_and_add.dart';
import 'widgets/filter_tabs.dart';
import 'widgets/booking_card.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

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
            // 1. Thanh tìm kiếm và nút Add
            SearchAndAdd(),

            // 2. Các tab filter
            FilterTabs(),

            // 3. Danh sách booking
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Đây là nơi ta code cứng (hardcode) dữ liệu
                  // Sau này sẽ thay bằng ListView.builder
                  BookingCard(
                    customerName: "Nguyễn Văn A",
                    phone: "0901234567",
                    studioName: "Studio Music Pro",
                    date: "2025-10-20",
                    time: "09:00 - 11:00",
                    price: "500.000đ",
                    status: BookingStatus.confirmed, // Đã xác nhận
                  ),
                  SizedBox(height: 16),
                  BookingCard(
                    customerName: "Trần Thị B",
                    phone: "0912345678",
                    studioName: "Studio Photo 1",
                    date: "2025-10-20",
                    time: "13:00 - 15:00",
                    price: "400.000đ",
                    status: BookingStatus.pending, // Chờ xác nhận
                  ),
                  SizedBox(height: 16),
                  BookingCard(
                    customerName: "Hoàng Văn E",
                    phone: "0945678901",
                    studioName: "Studio Photo 2",
                    date: "2025-10-21",
                    time: "19:00 - 21:00",
                    price: "450.000đ",
                    status: BookingStatus.cancelled, // Đã hủy
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
