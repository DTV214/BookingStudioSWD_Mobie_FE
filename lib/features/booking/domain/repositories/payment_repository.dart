import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/payment.dart';
import '../entities/final_payment.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<Payment>>> getByBookingId(String bookingId);

  /// POST /api/payments/booking/{bookingId}/final
  /// body: { "paymentMethod": "VNPAY" | "MOMO" | "CASH" }
  Future<Either<Failure, FinalPayment>> createFinalPayment({
    required String bookingId,
    required String paymentMethod,
  });
}
