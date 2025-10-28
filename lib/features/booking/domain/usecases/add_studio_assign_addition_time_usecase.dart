import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/addition_time_result.dart';
import '../repositories/studio_assign_repository.dart';

class AddStudioAssignAdditionTimeUsecase {
  final StudioAssignRepository repository;

  AddStudioAssignAdditionTimeUsecase(this.repository);

  Future<Either<Failure, AdditionTimeResult>> call({
    required String assignId,
    required int additionMinutes,
  }) {
    return repository.addAdditionTime(
      assignId: assignId,
      additionMinutes: additionMinutes,
    );
  }
}
