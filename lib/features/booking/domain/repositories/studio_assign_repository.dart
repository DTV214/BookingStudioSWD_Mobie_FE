import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/studio_assign.dart';
import '../entities/addition_time_result.dart';

abstract class StudioAssignRepository {
  Future<Either<Failure, List<StudioAssign>>> getByBookingId(String bookingId);

  Future<Either<Failure, Unit>> setStatus({
    required String assignId,
    required String status,
  });

  /// PATCH/POST /api/studio-assigns/{assignId}/addition-time
  /// body: { "additionMinutes": int }
  Future<Either<Failure, AdditionTimeResult>> addAdditionTime({
    required String assignId,
    required int additionMinutes,
  });
}
