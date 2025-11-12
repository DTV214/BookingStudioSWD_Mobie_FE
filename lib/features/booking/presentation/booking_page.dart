import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/search_and_add.dart';
import 'widgets/booking_card.dart';
import 'providers/booking_provider.dart';
import '../domain/entities/booking.dart';
import '../domain/entities/booking_status.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final Color primaryColor = const Color(0xFF6A40D3);
  final Color backgroundColor = const Color(0xFFF4F6F9);

  String _search = '';
  /// 'ALL' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED' | 'AWAITING_REFUND'
  String _status = 'ALL';
  late DateTime _selectedDate;
  bool _allDates = false; // ✅ mới: xem tất cả ngày

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day); // mặc định hôm nay
  }

  String _statusCode(BookingStatus s) {
    switch (s) {
      case BookingStatus.inProgress:
        return 'IN_PROGRESS';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
      case BookingStatus.awaitingRefund:
        return 'AWAITING_REFUND';
      case BookingStatus.awaitingPayment:
        return 'AWAITING_PAYMENT';
      case BookingStatus.confirmed:
        return 'CONFIRMED';
      case BookingStatus.unknown:
        return 'UNKNOWN';
    }
  }


  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Booking> _applyFilters(List<Booking> list) {
    final q = _search.trim().toLowerCase();

    return list.where((b) {
      // Search
      if (q.isNotEmpty) {
        final haystack = [
          b.customerName,
          b.phone ?? '',
          b.studioName,
          b.accountEmail,
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }

      // Status
      if (_status != 'ALL' && _statusCode(b.status) != _status) {
        return false;
      }

      // Date (bỏ qua nếu “Tất cả lịch” = true)
      if (!_allDates && !_sameDate(b.bookingDate, _selectedDate)) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      initialDate: _selectedDate,
      helpText: 'Chọn ngày',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          "Studio Manager",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          SearchAndAdd(
            searchText: _search,
            onSearchChanged: (v) => setState(() => _search = v),
            statusFilter: _status,
            onStatusChanged: (v) => setState(() => _status = v),
            selectedDate: _selectedDate,
            onPickDate: () => _pickDate(context),
            allDates: _allDates,                          // ✅ mới
            onAllDatesChanged: (v) => setState(() {       // ✅ mới
              _allDates = v;
            }),
            onAdd: () {
              // TODO: xử lý thêm booking mới
            },
          ),

          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, provider, child) {
                if (provider.state == BookingState.loading) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (provider.state == BookingState.error) {
                  return Center(
                    child: Text(
                      provider.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (provider.state == BookingState.loaded &&
                    provider.bookings.isEmpty) {
                  return const Center(child: Text("Không tìm thấy booking nào."));
                }

                final filtered = _applyFilters(provider.bookings);

                if (filtered.isEmpty) {
                  return const Center(child: Text("Không có booking khớp bộ lọc."));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final booking = filtered[index];
                    return BookingCard(booking: booking);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
