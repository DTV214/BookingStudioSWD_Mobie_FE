import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failure.dart';
import '../entities/service_assign.dart';
import '../repositories/service_assign_repository.dart';

class GetServiceAssignsByStudioAssign
    implements UseCase<List<ServiceAssign>, String> {
  final ServiceAssignRepository repository;
  GetServiceAssignsByStudioAssign(this.repository);

  @override
  Future<Either<Failure, List<ServiceAssign>>> call(String studioAssignId) {
    return repository.getByStudioAssignId(studioAssignId);
  }
}
