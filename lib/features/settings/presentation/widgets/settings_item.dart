// lib/features/settings/presentation/widgets/settings_item.dart
import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: TextStyle(fontSize: 16)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: Colors.grey))
          : null,
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
    );
  }
}
