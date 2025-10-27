import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ✅ Dùng absolute import + alias 'bd'
import 'package:swd_mobie_flutter/features/booking/presentation/widgets/booking_detail_page.dart'
as bd;

import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../providers/booking_provider.dart'; // để reload khi back

class BookingCard extends StatelessWidget {
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
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.calendar_today,
            DateFormat('dd/MM/yyyy').format(booking.bookingDate),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time,
            DateFormat('HH:mm').format(booking.bookingDate),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    Color statusColor;
    String statusText;
    Color statusTagColor;

    switch (booking.status) {
      case BookingStatus.inProgress:
        statusColor = Colors.blue;
        statusText = "Đang thực hiện";
        statusTagColor = Colors.blue.shade50;
        break;
      case BookingStatus.completed:
        statusColor = Colors.green;
        statusText = "Hoàn tất";
        statusTagColor = Colors.green.shade50;
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusText = "Đã hủy";
        statusTagColor = Colors.red.shade50;
        break;
      case BookingStatus.awaitingRefund:
        statusColor = Colors.deepPurple;
        statusText = "Chờ hoàn tiền";
        statusTagColor = Colors.deepPurple.shade50;
        break;
      default:
        statusColor = Colors.grey;
        statusText = "Không rõ";
        statusTagColor = Colors.grey.shade50;
    }

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
              booking.customerName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              booking.phone ?? "Không có SĐT",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              priceString,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A40D3),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Center(
      child: TextButton(
        child: const Text(
          "Xem chi tiết",
          style: TextStyle(
            color: Color(0xFF6A40D3),
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => bd.BookingDetailPage(booking: booking),
            ),
          );
          // Quay về → reload danh sách booking
          if (context.mounted) {
            try {
              await context.read<BookingProvider>().fetchBookings();
            } catch (_) {
              // nếu chưa inject BookingProvider ở trên cây widget thì bỏ qua
            }
          }
        },
      ),
    );
  }
}
