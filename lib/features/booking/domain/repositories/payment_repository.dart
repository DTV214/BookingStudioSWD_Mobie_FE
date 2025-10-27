import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<Payment>>> getByBookingId(String bookingId);
}
