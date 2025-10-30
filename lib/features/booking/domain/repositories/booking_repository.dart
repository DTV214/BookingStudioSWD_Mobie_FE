// lib/features/booking/domain/repositories/booking_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/booking.dart';

// Đây là một "hợp đồng" (contract)
// Lớp Presentation sẽ chỉ làm việc với interface này
abstract class BookingRepository {
  // Lấy danh sách tất cả các booking
  // Trả về một Failure (lỗi) hoặc một List<Booking> (thành công)
  Future<Either<Failure, List<Booking>>> getBookings();

  // (Sau này chúng ta có thể thêm các phương thức khác)
  // Future<Either<Failure, Booking>> getBookingDetail(String id);
  // Future<Either<Failure, void>> confirmBooking(String id);
  // Future<Either<Failure, void>> cancelBooking(String id);
  Future<Either<Failure, Booking>> getBookingDetail(String bookingId);
}
