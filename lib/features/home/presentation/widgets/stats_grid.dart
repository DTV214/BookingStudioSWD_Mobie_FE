// lib/features/home/presentation/widgets/stats_grid.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../booking/domain/entities/booking.dart';
import '../../../studio/presentation/providers/studio_provider.dart';
import '../../../studio/domain/entities/studio.dart';

class StatsGrid extends StatefulWidget {
  const StatsGrid({super.key});

  @override
  State<StatsGrid> createState() => _StatsGridState();
}

class _StatsGridState extends State<StatsGrid> {
  @override
  void initState() {
    super.initState();
    // Trigger fetch studios nếu chưa tải
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final studioProv = context.read<StudioProvider>();
      if (studioProv.state == StudioState.initial) {
        await studioProv.fetchStudios();
      }
      // BookingProvider của bạn đã auto fetch trong constructor,
      // nên không cần gọi lại ở đây.
    });
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookingProvider, StudioProvider>(
      builder: (context, bookingProv, studioProv, _) {
        // --- BOOKING TODAY ---
        final now = DateTime.now();
        int bookingTodayCount = 0;
        if (bookingProv.state == BookingState.loaded) {
          bookingTodayCount = bookingProv.bookings
              .where((Booking b) => _sameDate(b.bookingDate, now))
              .length;
        }

        // --- STUDIOS ---
        int totalStudios = 0;
        int availableStudios = 0;
        int maintenanceStudios = 0;

        if (studioProv.state == StudioState.loaded) {
          final List<Studio> studios = studioProv.studios;
          totalStudios = studios.length;
          availableStudios = studios
              .where((s) => s.status == StudioStatus.available)
              .length;
          maintenanceStudios = studios
              .where((s) => s.status == StudioStatus.maintenance)
              .length;
        }

        // Hiển thị skeleton nhẹ nếu đang loading
        final isLoadingAny =
            (bookingProv.state == BookingState.loading) ||
                (studioProv.state == StudioState.loading) ||
                (bookingProv.state == BookingState.initial) ||
                (studioProv.state == StudioState.initial);

        if (isLoadingAny) {
          return GridView.count(
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: const [
              _StatCardSkeleton(title: "Booking hôm nay"),
              _StatCardSkeleton(title: "Đang sử dụng"),
              _StatCardSkeleton(title: "Tổng studio"),
              _StatCardSkeleton(title: "Bảo trì"),
            ],
          );
        }

        // Nếu có lỗi, vẫn render với số 0 và hiện tooltip trong title (tránh vỡ UI)
        final bookingTitle = (bookingProv.state == BookingState.error)
            ? "Booking hôm nay (lỗi)"
            : "Booking hôm nay";
        final usingTitle = (studioProv.state == StudioState.error)
            ? "Đang sử dụng (lỗi)"
            : "Đang sử dụng";
        final totalTitle = (studioProv.state == StudioState.error)
            ? "Tổng studio (lỗi)"
            : "Tổng studio";
        final maintenanceTitle = (studioProv.state == StudioState.error)
            ? "Bảo trì (lỗi)"
            : "Bảo trì";

        return GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
          children: [
            _StatCard(
              icon: Icons.calendar_today,
              iconColor: Colors.blue,
              title: bookingTitle,
              value: "$bookingTodayCount",
            ),
            _StatCard(
              icon: Icons.play_circle_fill,
              iconColor: Colors.green,
              title: usingTitle, // AVAILABLE
              value: "$availableStudios",
            ),
            _StatCard(
              icon: Icons.apartment, // đổi icon cho hợp "Tổng studio"
              iconColor: Colors.purple,
              title: totalTitle,
              value: "$totalStudios",
            ),
            _StatCard(
              icon: Icons.build_circle, // bảo trì
              iconColor: Colors.orange,
              title: maintenanceTitle, // MAINTENANCE
              value: "$maintenanceStudios",
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  final String title;
  const _StatCardSkeleton({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade200,
            child: const SizedBox(width: 20, height: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Container(
                  height: 18,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
