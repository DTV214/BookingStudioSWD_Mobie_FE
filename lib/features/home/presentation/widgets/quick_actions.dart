// lib/features/home/presentation/widgets/quick_actions.dart
import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF6A40D3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Thao tác nhanh",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              // 1. Sử dụng widget con _QuickActionItem
              child: _QuickActionItem(
                context: context,
                icon: Icons.add_circle_outline,
                label: "Đặt lịch mới",
                backgroundColor: primaryColor,
                iconColor: Colors.white,
                labelColor: Colors.white,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              // 2. Sử dụng widget con _QuickActionItem
              child: _QuickActionItem(
                context: context,
                icon: Icons.notifications_outlined,
                label: "Thông báo",
                backgroundColor: Colors.white,
                iconColor: primaryColor,
                labelColor: primaryColor,
                borderColor: primaryColor.withOpacity(0.5),
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Widget cho 1 nút thao tác nhanh (private)
class _QuickActionItem extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color labelColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.context,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.labelColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: labelColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
