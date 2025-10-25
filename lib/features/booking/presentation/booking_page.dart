import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/search_and_add.dart';
import 'widgets/filter_tabs.dart';
import 'widgets/booking_card.dart';
import 'providers/booking_provider.dart'; // 1. Import Provider

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF6A40D3);
    final Color backgroundColor = Color(0xFFF4F6F9);

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
          // 2. Các widget UI tĩnh (giữ nguyên)
          SearchAndAdd(),
          FilterTabs(),

          // 3. Phần body (danh sách) sẽ được quản lý bởi Provider
          Expanded(
            // 4. Lắng nghe thay đổi từ BookingProvider
            child: Consumer<BookingProvider>(
              builder: (context, provider, child) {
                // 5. Xử lý các trạng thái
                if (provider.state == BookingState.loading) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (provider.state == BookingState.error) {
                  return Center(
                    child: Text(
                      provider.message,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (provider.state == BookingState.loaded &&
                    provider.bookings.isEmpty) {
                  return Center(child: Text("Không tìm thấy booking nào."));
                }

                // 6. Trạng thái loaded (thành công)
                return ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: provider.bookings.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    // Lấy booking tại vị trí index
                    final booking = provider.bookings[index];
                    // Truyền object booking vào card
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
