// lib/features/home/presentation/widgets/today_schedule.dart
import 'package:flutter/material.dart';

class TodaySchedule extends StatelessWidget {
  const TodaySchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              onPressed: () {},
              child: const Text(
                "Xem tất cả",
                style: TextStyle(
                  color: Color(0xFF6A40D3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 1. Sử dụng _ScheduleCard
        const _ScheduleCard(
          customerName: "Nguyễn Văn A",
          studioName: "Studio Music Pro",
          time: "09:00 - 11:00",
          status: "Đã xác nhận",
          statusColor: Colors.green,
        ),
        const SizedBox(height: 12),
        // 2. Sử dụng _ScheduleCard
        const _ScheduleCard(
          customerName: "Trần Thị B",
          studioName: "Studio Photo 1",
          time: "13:00 - 15:00",
          status: "Chờ xác nhận",
          statusColor: Colors.orange,
        ),
      ],
    );
  }
}

// Widget cho 1 card lịch (private)
class _ScheduleCard extends StatelessWidget {
  final String customerName;
  final String studioName;
  final String time;
  final String status;
  final Color statusColor;

  const _ScheduleCard({
    required this.customerName,
    required this.studioName,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                studioName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
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
    );
  }
}
