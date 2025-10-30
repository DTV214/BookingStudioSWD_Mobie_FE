import 'package:dartz/dartz.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Booking>>> getBookings() async {
    // LOG 4 (MỚI)
    print("[BookingRepository] getBookings() ĐANG CHẠY...");
    try {
      // LOG 5 (MỚI)
      print(
        "[BookingRepository] Chuẩn bị gọi remoteDataSource.getBookings()...",
      );
      final remoteBookings = await remoteDataSource.getBookings();

      // LOG 6 (MỚI)
      print(
        "[BookingRepository] Đã gọi remoteDataSource thành công. Trả về Right(remoteBookings).",
      );
      return Right(remoteBookings);
    } on ServerException {
      // LOG 7 (MỚI)
      print(
        "[BookingRepository] Bắt lỗi ServerException. Trả về Left(ServerFailure).",
      );
      return Left(ServerFailure());
    } on NetworkException {
      // LOG 8 (MỚI - SỬA LỖI)
      // Bắt đúng NetworkException mà DataSource ném ra
      print(
        "[BookingRepository] Bắt lỗi NetworkException. Trả về Left(NetworkFailure).",
      );
      return Left(NetworkFailure());
    } catch (e) {
      // LOG 9 (MỚI)
      print(
        "[BookingRepository] Bắt lỗi KHÔNG LƯỜNG TRƯỚC: $e. Trả về Left(ServerFailure).",
      );
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingDetail(String bookingId) async {
    try {
      // Gọi phương thức từ Remote Data Source
      final result = await remoteDataSource.getBookingDetail(bookingId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure());
    }
  }
}
