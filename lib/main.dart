import 'package:flutter/material.dart';
import 'layout/main_layout.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Footer Menu',
      theme: AppTheme.lightTheme,
      home: const MainLayout(),
    );
  }
}
