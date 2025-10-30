import 'package:dartz/dartz.dart';
import 'package:swd_mobie_flutter/core/error/failure.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class GetBookingDetailUsecase{
  final BookingRepository repository;

  GetBookingDetailUsecase(this.repository);

  Future<Either<Failure, Booking>> call(String bookingId) async {
    return repository.getBookingDetail(bookingId);
  }
}
