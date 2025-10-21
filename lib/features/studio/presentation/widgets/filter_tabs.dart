// lib/features/studio/presentation/widgets/filter_tabs.dart
import 'package:flutter/material.dart';

class FilterTabs extends StatefulWidget {
  const FilterTabs({super.key});

  @override
  State<FilterTabs> createState() => _FilterTabsState();
}

class _FilterTabsState extends State<FilterTabs> {
  int _selectedIndex = 0;
  // Sửa lại labels
  final List<String> _tabs = ["Tất cả", "Music", "Photo", "Dance"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
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
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: Colors.white,
            selectedColor: Color(0xFF6A40D3), // Đảo màu cho giống UI
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? Color(0xFF6A40D3) : Colors.grey.shade300,
              ),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
