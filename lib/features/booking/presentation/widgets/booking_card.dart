// lib/features/booking/presentation/widgets/booking_card.dart
import 'package:flutter/material.dart';

// 1. Định nghĩa các trạng thái
enum BookingStatus { pending, confirmed, cancelled }

class BookingCard extends StatelessWidget {
  final String customerName;
  final String phone;
  final String studioName;
  final String date;
  final String time;
  final String price;
  final BookingStatus status;

  const BookingCard({
    super.key,
    required this.customerName,
    required this.phone,
    required this.studioName,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Divider(height: 24, color: Colors.grey[200]),
          _buildInfoRow(Icons.music_note, studioName),
          SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today, date),
          SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, time),
          SizedBox(height: 16),
          // 4. Hiển thị nút bấm tùy theo status
          _buildActionButtons(),
        ],
      ),
    );
  }

  // 2. Tách nhỏ các phần bên trong card
  Widget _buildHeader() {
    Color statusColor;
    String statusText;
    Color statusTagColor;

    switch (status) {
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusText = "Chờ xác nhận";
        statusTagColor = Colors.orange.shade50;
        break;
      case BookingStatus.confirmed:
        statusColor = Colors.green;
        statusText = "Đã xác nhận";
        statusTagColor = Colors.green.shade50;
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusText = "Đã hủy";
        statusTagColor = Colors.red.shade50;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customerName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(phone, style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              price,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A40D3),
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusTagColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  // 3. Widget quyết định hiển thị nút nào
  Widget _buildActionButtons() {
    if (status == BookingStatus.pending) {
      // Hiển thị 2 nút "Xác nhận" và "Hủy"
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: Icon(Icons.check_circle_outline),
              label: Text("Xác nhận"),
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              icon: Icon(Icons.cancel_outlined),
              label: Text("Hủy"),
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Hiển thị nút "Chi tiết" cho các trạng thái khác
    return Center(
      child: TextButton(
        child: Text(
          "Chi tiết",
          style: TextStyle(
            color: Color(0xFF6A40D3),
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () {
          // TODO: Mở trang chi tiết
        },
      ),
    );
  }
}
