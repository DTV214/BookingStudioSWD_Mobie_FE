import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/exception.dart';
import '../../domain/entities/service_assign.dart';
import '../../domain/repositories/service_assign_repository.dart';
import '../datasources/service_assign_remote_data_source.dart';

class ServiceAssignRepositoryImpl implements ServiceAssignRepository {
  final ServiceAssignRemoteDataSource remote;

  ServiceAssignRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<ServiceAssign>>> getByStudioAssignId(
      String studioAssignId) async {
    try {
      final models = await remote.getByStudioAssignId(studioAssignId);
      return Right(models);
    } on NetworkException {
      return Left(NetworkFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
