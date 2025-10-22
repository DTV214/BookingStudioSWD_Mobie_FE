import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm thư viện intl để format ngày và tiền
import '../../domain/entities/booking.dart'; // Import Entity
import '../../domain/entities/booking_status.dart'; // Import Enum

class BookingCard extends StatelessWidget {
  // Thay vì nhiều trường, chỉ cần 1 object Booking
  final Booking booking;

  const BookingCard({super.key, required this.booking});

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
          _buildInfoRow(Icons.music_note, booking.studioName),
          SizedBox(height: 8),
          _buildInfoRow(
            Icons.calendar_today,
            DateFormat('dd/MM/yyyy').format(booking.bookingDate),
          ),
          SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time,
            DateFormat('HH:mm').format(booking.bookingDate),
          ), // Giả sử time
          SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    Color statusColor;
    String statusText;
    Color statusTagColor;

    // Dùng booking.status (Enum)
    switch (booking.status) {
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
      default: // Cho trường hợp unknown
        statusColor = Colors.grey;
        statusText = "Không rõ";
        statusTagColor = Colors.grey.shade50;
    }

    // Format tiền tệ
    final priceString = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    ).format(booking.total);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.customerName, // Lấy từ booking.customerName
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              // Kiểm tra phone null
              booking.phone ?? "Không có SĐT",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              priceString, // Dùng giá đã format
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

  Widget _buildActionButtons() {
    if (booking.status == BookingStatus.pending) {
      // (Giữ nguyên logic nút bấm của bạn)
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: Icon(Icons.check_circle_outline),
              label: Text("Xác nhận"),
              onPressed: () {
                // TODO: Gọi provider.confirmBooking(booking.id)
              },
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
              onPressed: () {
                // TODO: Gọi provider.cancelBooking(booking.id)
              },
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
