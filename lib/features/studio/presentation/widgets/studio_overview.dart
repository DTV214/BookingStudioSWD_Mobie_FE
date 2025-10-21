// lib/features/studio/presentation/widgets/studio_overview.dart
import 'package:flutter/material.dart';

class StudioOverview extends StatelessWidget {
  const StudioOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tổng quan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem(Icons.mic, "5", "Tổng studio", Colors.purple),
              _buildOverviewItem(
                Icons.calendar_month,
                "30",
                "Booking",
                Colors.green,
              ),
              _buildOverviewItem(
                Icons.attach_money,
                "7.05M",
                "Doanh thu",
                Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
