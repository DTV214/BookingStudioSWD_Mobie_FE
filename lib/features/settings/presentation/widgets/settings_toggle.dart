// lib/features/settings/presentation/widgets/settings_toggle.dart
import 'package:flutter/material.dart';

class SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final Function(bool) onChanged;

  const SettingsToggle({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF6A40D3),
      ),
      onTap: () {
        // Cho phép nhấn cả hàng
        onChanged(!value);
      },
    );
  }
}
