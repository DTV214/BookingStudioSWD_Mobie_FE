// lib/features/booking/presentation/widgets/filter_tabs.dart
import 'package:flutter/material.dart';

class FilterTabs extends StatefulWidget {
  const FilterTabs({super.key});

  @override
  State<FilterTabs> createState() => _FilterTabsState();
}

class _FilterTabsState extends State<FilterTabs> {
  int _selectedIndex = 0;
  final List<String> _tabs = ["Tất cả", "Đã xác nhận", "Chờ", "Đã hủy"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Chiều cao cố định cho dải tab
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (context, index) => SizedBox(width: 12),
        itemBuilder: (context, index) {
          bool isSelected = _selectedIndex == index;
          return ChoiceChip(
            label: Text(_tabs[index]),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelStyle: TextStyle(
              color: isSelected ? Color(0xFF6A40D3) : Colors.black,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Color(0xFFF4F6F9),
            selectedColor: Color(0xFF6A40D3).withOpacity(0.1),
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? Color(0xFF6A40D3) : Colors.transparent,
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
