import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart'; // Cần để lấy màu

class BookingDetailPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF6A40D3);
    final Color backgroundColor = Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Chi tiết Booking"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ thông tin khách hàng
            _buildCustomerCard(context),
            SizedBox(height: 16),
            // 2. Thẻ thông tin booking
            _buildBookingInfoCard(context),
            SizedBox(height: 16),
            // 3. Khu vực thanh toán (Placeholder)
            _buildPaymentSection(context),
            SizedBox(height: 16),
            // 4. Khu vực dịch vụ (Placeholder)
            _buildServiceSection(context),
          ],
        ),
      ),
    );
  }

  // Card thông tin khách hàng
  Widget _buildCustomerCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.customerName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildInfoRow(Icons.email_outlined, booking.accountEmail),
            SizedBox(height: 8),
            _buildInfoRow(Icons.phone_outlined, booking.phone ?? "Chưa có SĐT"),
          ],
        ),
      ),
    );
  }

  // Card thông tin lịch đặt
  Widget _buildBookingInfoCard(BuildContext context) {
    // Lấy màu và text từ status (giống hệt logic trong BookingCard)
    Color statusColor;
    String statusText;
    switch (booking.status) {
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusText = "Chờ xác nhận";
        break;
      case BookingStatus.confirmed:
        statusColor = Colors.green;
        statusText = "Đã xác nhận";
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusText = "Đã hủy";
        break;
      default:
        statusColor = Colors.grey;
        statusText = "Không rõ";
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Thông tin Lịch đặt",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            _buildInfoRow(Icons.music_note_outlined, booking.studioName),
            SizedBox(height: 8),
            _buildInfoRow(Icons.category_outlined, booking.studioTypeName),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              DateFormat('dd/MM/yyyy').format(booking.bookingDate),
            ),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time_outlined,
              DateFormat('HH:mm').format(booking.bookingDate),
            ),
            SizedBox(height: 8),
            _buildInfoRow(
              Icons.article_outlined,
              booking.note ?? "Không có ghi chú",
            ),
          ],
        ),
      ),
    );
  }

  // Khu vực thanh toán (có placeholder)
  Widget _buildPaymentSection(BuildContext context) {
    final priceString = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    ).format(booking.total);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thông tin Thanh toán",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Divider(height: 24),
            // Chúng ta có sẵn 'total' từ object Booking
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.monetization_on_outlined,
                color: Colors.green,
              ),
              title: Text("Tổng tiền"),
              trailing: Text(
                priceString,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            // TODO: Placeholder cho các chi tiết payment khác
            // Khi có API (ví dụ: /api/payments/booking/{id})
            // chúng ta sẽ gọi và hiển thị ở đây (vd: phương thức, trạng thái...)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.credit_card_outlined, color: Colors.grey),
              title: Text("Phương thức thanh toán"),
              trailing: Text(
                "Đang tải...", // Placeholder
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Khu vực Dịch vụ (có placeholder)
  Widget _buildServiceSection(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dịch vụ đã đặt",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Divider(height: 24),
            // TODO: Placeholder cho chi tiết dịch vụ
            // Khi có API, chúng ta sẽ gọi và hiển thị 1 list dịch vụ ở đây.
            // Tạm thời, chúng ta để nút "Xem chi tiết" như bạn yêu cầu
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.design_services_outlined,
                color: Color(0xFF6A40D3),
              ),
              title: Text("Chi tiết các dịch vụ"),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Xử lý khi có API
                // (Hiển thị 1 dialog hoặc trang mới liệt kê dịch vụ)
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper tái sử dụng
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        SizedBox(width: 12),
        // Dùng Expanded để text tự xuống dòng nếu quá dài
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
