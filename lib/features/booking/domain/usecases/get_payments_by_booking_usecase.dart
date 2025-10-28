import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetPaymentsByBooking
    implements UseCase<List<Payment>, GetPaymentsByBookingParams> {
  final PaymentRepository repository;

  GetPaymentsByBooking(this.repository);

  @override
  Future<Either<Failure, List<Payment>>> call(
      GetPaymentsByBookingParams params) {
    return repository.getByBookingId(params.bookingId);
  }
}

class GetPaymentsByBookingParams {
  final String bookingId;
  GetPaymentsByBookingParams(this.bookingId);
}
