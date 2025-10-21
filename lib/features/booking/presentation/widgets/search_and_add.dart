// lib/features/booking/presentation/widgets/search_and_add.dart
import 'package:flutter/material.dart';

class SearchAndAdd extends StatelessWidget {
  const SearchAndAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Thanh tìm kiếm
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm booking...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Color(0xFFF4F6F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Nút Plus
          IconButton(
            icon: Icon(Icons.add_circle_rounded),
            color: Color(0xFF6A40D3),
            iconSize: 32,
            onPressed: () {
              // TODO: Xử lý thêm booking mới
            },
          ),
        ],
      ),
    );
  }
}
