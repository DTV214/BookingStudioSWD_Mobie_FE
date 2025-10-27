import 'package:dartz/dartz.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/studio_assign.dart';
import '../../domain/entities/addition_time_result.dart';
import '../../domain/repositories/studio_assign_repository.dart';
import '../datasources/studio_assign_remote_data_source.dart';

class StudioAssignRepositoryImpl implements StudioAssignRepository {
  final StudioAssignRemoteDataSource remote;

  StudioAssignRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<StudioAssign>>> getByBookingId(String bookingId) async {
    try {
      final list = await remote.getByBookingId(bookingId);
      return Right(list);
    } on NetworkException {
      return Left(NetworkFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> setStatus({
    required String assignId,
    required String status,
  }) async {
    try {
      await remote.setStatus(assignId: assignId, status: status);
      return const Right(unit);
    } on NetworkException {
      return Left(NetworkFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AdditionTimeResult>> addAdditionTime({
    required String assignId,
    required int additionMinutes,
  }) async {
    try {
      final result = await remote.addAdditionTime(
        assignId: assignId,
        additionMinutes: additionMinutes,
      );
      return Right(result);
    } on NetworkException {
      return Left(NetworkFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
