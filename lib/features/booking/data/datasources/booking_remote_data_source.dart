import '../models/booking_model.dart';
import '../../../../core/error/exception.dart';

abstract class BookingRemoteDataSource {
  /// Gọi đến API endpoint `GET /api/bookings`
  ///
  /// Ném ra [ServerException] cho tất cả các mã lỗi (4xx, 5xx).
  /// Ném ra [NetworkException] khi có lỗi kết nối.
  Future<List<BookingModel>> getBookings();
}
