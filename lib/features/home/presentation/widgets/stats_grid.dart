// lib/features/home/presentation/widgets/stats_grid.dart
import 'package:flutter/material.dart';

// 1. Widget chính cho cả lưới 4 ô
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: const [
        // 2. Sử dụng widget con _StatCard
        _StatCard(
          icon: Icons.calendar_today,
          iconColor: Colors.blue,
          title: "Booking hôm nay",
          value: "12",
        ),
        _StatCard(
          icon: Icons.play_circle_fill,
          iconColor: Colors.green,
          title: "Đang sử dụng",
          value: "4",
        ),
        _StatCard(
          icon: Icons.people,
          iconColor: Colors.purple,
          title: "Khách hàng",
          value: "156",
        ),
        _StatCard(
          icon: Icons.attach_money,
          iconColor: Colors.orange,
          title: "Doanh thu",
          value: "8.5M",
        ),
      ],
    );
  }
}

// 3. Widget cho 1 ô (tương tự _buildStatCard cũ)
// Thêm dấu gạch dưới `_` để biến nó thành private,
// chỉ sử dụng nội bộ trong file này.
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
