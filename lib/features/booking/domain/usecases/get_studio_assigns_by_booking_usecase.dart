import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failure.dart';
import '../entities/studio_assign.dart';
import '../repositories/studio_assign_repository.dart';

class GetStudioAssignsByBooking implements UseCase<List<StudioAssign>, String> {
  final StudioAssignRepository repository;
  GetStudioAssignsByBooking(this.repository);

  @override
  Future<Either<Failure, List<StudioAssign>>> call(String bookingId) {
    return repository.getByBookingId(bookingId);
  }
}
