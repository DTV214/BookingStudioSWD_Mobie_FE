import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/final_payment.dart';
import '../repositories/payment_repository.dart';

class CreateFinalPaymentUsecase {
  final PaymentRepository repository;
  CreateFinalPaymentUsecase(this.repository);

  Future<Either<Failure, FinalPayment>> call({
    required String bookingId,
    required String paymentMethod,
  }) {
    return repository.createFinalPayment(
      bookingId: bookingId,
      paymentMethod: paymentMethod,
    );
  }
}
