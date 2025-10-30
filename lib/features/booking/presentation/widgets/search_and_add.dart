import 'package:flutter/material.dart';

class SearchAndAdd extends StatelessWidget {
  final String searchText;
  final ValueChanged<String> onSearchChanged;

  /// 'ALL' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED' | 'AWAITING_REFUND'
  final String statusFilter;
  final ValueChanged<String> onStatusChanged;

  /// Lọc theo ngày (bị bỏ qua nếu allDates = true)
  final DateTime selectedDate;
  final VoidCallback onPickDate;

  /// Bật để xem tất cả lịch (bỏ lọc ngày)
  final bool allDates;
  final ValueChanged<bool> onAllDatesChanged;

  final VoidCallback? onAdd;

  const SearchAndAdd({
    super.key,
    required this.searchText,
    required this.onSearchChanged,
    required this.statusFilter,
    required this.onStatusChanged,
    required this.selectedDate,
    required this.onPickDate,
    required this.allDates,
    required this.onAllDatesChanged,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final statusItems = const [
      DropdownMenuItem(value: 'ALL', child: Text('Tất cả trạng thái')),
      DropdownMenuItem(value: 'IN_PROGRESS', child: Text('Đang thực hiện')),
      DropdownMenuItem(value: 'COMPLETED', child: Text('Hoàn tất')),
      DropdownMenuItem(value: 'CANCELLED', child: Text('Đã hủy')),
      DropdownMenuItem(value: 'AWAITING_REFUND', child: Text('Chờ hoàn tiền')),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          // Hàng 1: Search + Add
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,
                  controller: TextEditingController(text: searchText)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: searchText.length),
                    ),
                  decoration: InputDecoration(
                    hintText: "Tên/điện thoại/studio...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF4F6F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.add_circle_rounded),
                color: const Color(0xFF6A40D3),
                iconSize: 32,
                onPressed: onAdd ?? () {},
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Hàng 2: Status dropdown + Date picker
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: statusFilter,
                  items: statusItems,
                  onChanged: (v) => onStatusChanged(v ?? 'ALL'),
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: allDates ? null : onPickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: allDates ? 'Ngày (đang xem tất cả)' : 'Ngày',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.event),
                      enabled: !allDates,
                    ),
                    child: Text(
                      "${selectedDate.day.toString().padLeft(2, '0')}/"
                          "${selectedDate.month.toString().padLeft(2, '0')}/"
                          "${selectedDate.year}",
                      style: TextStyle(
                        fontSize: 14,
                        color: allDates ? Colors.grey : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Hàng 3: Công tắc “Tất cả lịch”
          Row(
            children: [
              Switch(
                value: allDates,
                onChanged: onAllDatesChanged,
              ),
              const SizedBox(width: 4),
              const Text(
                'Tất cả lịch',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Bật để hiển thị mọi ngày.',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
