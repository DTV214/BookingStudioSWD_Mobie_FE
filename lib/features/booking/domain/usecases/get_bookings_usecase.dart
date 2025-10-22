import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

// Usecase này triển khai (implements) từ UseCase base
// Nó trả về List<Booking> và không cần tham số (NoParams)
class GetBookingsUsecase implements UseCase<List<Booking>, NoParams> {
  // Usecase này phụ thuộc vào Repository (interface, không phải impl)
  final BookingRepository repository;

  GetBookingsUsecase(this.repository);

  // Khi Provider gọi usecase, nó sẽ gọi hàm 'call' này
  @override
  Future<Either<Failure, List<Booking>>> call(NoParams params) async {
    // Logic nghiệp vụ có thể được thêm ở đây
    // Ví dụ: lọc, sắp xếp dữ liệu...
    // Tạm thời, chúng ta chỉ gọi thẳng đến repository
    return await repository.getBookings();
  }
}
