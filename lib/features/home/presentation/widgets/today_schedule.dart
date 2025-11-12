// lib/features/home/presentation/widgets/today_schedule.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Booking domain + provider
import 'package:swd_mobie_flutter/features/booking/domain/entities/booking.dart';
import 'package:swd_mobie_flutter/features/booking/domain/entities/booking_status.dart';
import 'package:swd_mobie_flutter/features/booking/presentation/providers/booking_provider.dart';

// Booking pages
import 'package:swd_mobie_flutter/features/booking/presentation/booking_page.dart';
import 'package:swd_mobie_flutter/features/booking/presentation/widgets/booking_detail_page.dart'
as bd;

class TodaySchedule extends StatelessWidget {
  const TodaySchedule({super.key});

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  (String, Color) _statusTextAndColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.inProgress:
        return ("Đang thực hiện", Colors.blue);
      case BookingStatus.confirmed:
        return ("Đã xác nhận", Colors.teal);
      case BookingStatus.completed:
        return ("Hoàn tất", Colors.green);
      case BookingStatus.cancelled:
        return ("Đã hủy", Colors.red);
      case BookingStatus.awaitingPayment:
        return ("Chờ thanh toán", Colors.orange);
      case BookingStatus.awaitingRefund:
        return ("Chờ hoàn tiền", Colors.deepPurple);
      case BookingStatus.unknown:
        return ("Không rõ", Colors.grey);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, prov, _) {
        // Header
        final header = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Lịch đặt hôm nay",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingPage()),
                );
              },
              child: const Text(
                "Xem tất cả",
                style: TextStyle(
                  color: Color(0xFF6A40D3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );

        if (prov.state == BookingState.loading ||
            prov.state == BookingState.initial) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 8),
              const _ScheduleCardSkeleton(),
              const SizedBox(height: 12),
              const _ScheduleCardSkeleton(),
            ],
          );
        }

        if (prov.state == BookingState.error) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 8),
              Text(
                prov.message,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          );
        }

        // Lọc các booking có ngày == hôm nay
        final now = DateTime.now();
        final todays = prov.bookings
            .where((b) => _sameDate(b.bookingDate, now))
            .toList();

        // Lấy tối đa 2 booking để show nhanh
        final items = todays.take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text(
                "Hôm nay chưa có lịch đặt.",
                style: TextStyle(color: Colors.grey),
              )
            else
              ...items.map((b) {
                final timeStr = DateFormat('HH:mm').format(b.bookingDate);
                final (statusText, statusColor) = _statusTextAndColor(b.status);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ScheduleCard(
                    customerName: b.customerName,
                    studioName: b.studioName,
                    time: timeStr, // nếu cần range thì lấy từ assigns ở trang detail
                    status: statusText,
                    statusColor: statusColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => bd.BookingDetailPage(booking: b),
                        ),
                      );
                    },
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

// ===== Card item hiển thị 1 lịch hôm nay =====
class _ScheduleCard extends StatelessWidget {
  final String customerName;
  final String studioName;
  final String time;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;

  const _ScheduleCard({
    required this.customerName,
    required this.studioName,
    required this.time,
    required this.status,
    required this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  studioName,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            // Right tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Skeleton khi loading
class _ScheduleCardSkeleton extends StatelessWidget {
  const _ScheduleCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade200;
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 16, width: 140, color: base),
              const SizedBox(height: 8),
              Container(height: 14, width: 110, color: base),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(height: 14, width: 14, color: base),
                  const SizedBox(width: 6),
                  Container(height: 14, width: 60, color: base),
                ],
              ),
            ],
          ),
          // Right tag skeleton
          Container(height: 22, width: 90, color: base, margin: EdgeInsets.zero),
        ],
      ),
    );
  }
}
