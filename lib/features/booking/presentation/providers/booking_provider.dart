import 'package:flutter/material.dart';
import '../../../../core/usecases/usecase.dart'; // Để dùng NoParams
import '../../domain/entities/booking.dart';
import '../../domain/usecases/get_bookings_usecase.dart';

// 1. Định nghĩa các trạng thái cho UI
enum BookingState { initial, loading, loaded, error }

class BookingProvider extends ChangeNotifier {
  final GetBookingsUsecase getBookingsUsecase;

  BookingProvider({required this.getBookingsUsecase}) {
    // LOG 1
    print(
      "[BookingProvider] Constructor được gọi. Chuẩn bị gọi fetchBookings()...",
    );
    // Tự động gọi API khi Provider được tạo
    fetchBookings();
  }

  // 2. Quản lý trạng thái (State)
  BookingState _state = BookingState.initial;
  BookingState get state => _state;

  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings; // UI sẽ lấy danh sách này

  String _message = '';
  String get message => _message; // Để hiển thị thông báo lỗi

  // 3. Hàm gọi API
  Future<void> fetchBookings() async {
    // LOG 2
    print("[BookingProvider] fetchBookings() BẮT ĐẦU. Đặt state = loading.");
    // Cập nhật UI sang trạng thái loading
    _state = BookingState.loading;
    notifyListeners();

    // Gọi Usecase (Không cần tham số)
    final failureOrBookings = await getBookingsUsecase(NoParams());

    // Xử lý kết quả trả về
    failureOrBookings.fold(
      (failure) {
        // Nếu thất bại
        _message = "Lỗi: Không thể tải danh sách booking.";
        _state = BookingState.error;
        // LOG 3 (Lỗi)
        print(
          "[BookingProvider] fetchBookings() THẤT BẠI. Lỗi: ${failure.toString()}",
        );
      },
      (bookingList) {
        // Nếu thành công
        _bookings = bookingList;
        _state = BookingState.loaded;
        // LOG 3 (Thành công)
        print(
          "[BookingProvider] fetchBookings() THÀNH CÔNG. Tải được ${bookingList.length} bookings.",
        );
      },
    );

    // Báo cho UI cập nhật (dù thành công hay thất bại)
    notifyListeners();
  }
}
