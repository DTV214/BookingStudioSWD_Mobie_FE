import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/studio_assign.dart';

abstract class StudioAssignRepository {
  Future<Either<Failure, List<StudioAssign>>> getByBookingId(String bookingId);
}
