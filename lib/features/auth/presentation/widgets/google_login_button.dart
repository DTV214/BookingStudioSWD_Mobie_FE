// lib/features/auth/presentation/widgets/google_login_button.dart
import 'package:flutter/material.dart';

class GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleLoginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.network(
        'https://res.cloudinary.com/dratbz8bh/image/upload/v1761055979/2048px-Google__22G_22_logo.svg_ahsqol.png', // BẠN CẦN THÊM ẢNH NÀY
        height: 24.0,
        width: 24.0,
      ),
      label: const Text(
        'Đăng nhập với Google',
        style: TextStyle(color: Colors.black87, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        minimumSize: const Size(double.infinity, 50), // Full width, 50 height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
