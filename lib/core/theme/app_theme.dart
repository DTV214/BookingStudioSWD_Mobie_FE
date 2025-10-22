import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 1. Import google_fonts

class AppTheme {
  // Màu chủ đạo bạn đang dùng
  static const Color _primaryColor = Color(0xFF6A40D3);
  static const Color _backgroundColor = Color(0xFFF4F6F9);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: _backgroundColor,

      // 2. Áp dụng font Inter cho toàn bộ ứng dụng
      // Nó sẽ tự động áp dụng cho các Text, Button, AppBar...
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: _primaryColor,
        titleTextStyle: GoogleFonts.inter(
          // 3. Đảm bảo AppBar cũng dùng font
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white), // Icon trên AppBar
      ),

      // Cấu hình màu cho các widget khác
      colorScheme: ColorScheme.light(
        primary: _primaryColor,
        secondary: Colors.amber,
        background: _backgroundColor,
      ),

      // Cấu hình style cho FilledButton (chúng ta sẽ dùng ở bước 3)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.0),
        ),
      ),
    );
  }
}
