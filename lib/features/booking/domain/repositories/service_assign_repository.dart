import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/service_assign.dart';

abstract class ServiceAssignRepository {
  Future<Either<Failure, List<ServiceAssign>>> getByStudioAssignId(String studioAssignId);
}
