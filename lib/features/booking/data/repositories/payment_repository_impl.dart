import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/exception.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/final_payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remote;

  PaymentRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Payment>>> getByBookingId(String bookingId) async {
    try {
      final list = await remote.getByBookingId(bookingId);
      return Right(list);
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, FinalPayment>> createFinalPayment({
    required String bookingId,
    required String paymentMethod,
  }) async {
    try {
      final fp = await remote.createFinalPayment(
        bookingId: bookingId,
        paymentMethod: paymentMethod,
      );
      return Right(fp);
    } on NetworkException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
