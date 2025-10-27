// lib/features/settings/presentation/widgets/profile_header.dart
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String id;
  final String avatarUrl;
  // ⭐ BƯỚC 1: Thêm dòng này để định nghĩa tham số
  final VoidCallback onEditPressed;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.id,
    required this.avatarUrl,
    // ⭐ BƯỚC 2: Thêm 'required' cho tham số mới ở constructor
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF6A40D3),
            // TODO: Thêm logic để load ảnh từ URL nếu avatarUrl là http
            child: Text(
              avatarUrl.length <= 2
                  ? avatarUrl
                  : "", // Chỉ hiện text nếu là 'NV'
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(email, style: TextStyle(fontSize: 14, color: Colors.grey)),
                SizedBox(height: 4),
                Text(
                  "ID: $id",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          TextButton(
            child: Text("Sửa"),
            // ⭐ BƯỚC 3: Gán hàm vào nút
            onPressed: onEditPressed,
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF6A40D3),
              backgroundColor: Color(0xFF6A40D3).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
