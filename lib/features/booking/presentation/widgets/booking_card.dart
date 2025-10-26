import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ✅ Dùng absolute import + alias 'bd'
import 'package:swd_mobie_flutter/features/booking/presentation/widgets/booking_detail_page.dart'
as bd;

import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';


class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  // ... (các hàm _buildHeader, _buildInfoRow giữ nguyên) ...
  // (Tôi sẽ copy lại các hàm đó ở đây cho bạn)

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
          // Sửa hàm này
          _buildActionButtons(context),
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

  // --- (PHẦN CẬP NHẬT) ---
  // Sửa hàm này
  Widget _buildActionButtons(BuildContext context) {
    // Xóa bỏ logic IF, luôn hiển thị nút "Chi tiết"
    return Center(
      child: TextButton(
        child: Text(
          "Xem chi tiết",
          style: TextStyle(
            color: Color(0xFF6A40D3),
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () {
          // Xử lý điều hướng
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => bd.BookingDetailPage(booking: booking),
            ),
          );
        },
      ),
    );
  }
}
