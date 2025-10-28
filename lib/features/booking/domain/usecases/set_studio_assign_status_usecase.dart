import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/studio_assign_repository.dart';

class SetStudioAssignStatusUsecase {
  final StudioAssignRepository repository;

  SetStudioAssignStatusUsecase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String assignId,
    required String status,
  }) {
    return repository.setStatus(assignId: assignId, status: status);
  }
}
