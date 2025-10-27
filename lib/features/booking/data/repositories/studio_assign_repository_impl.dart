import 'package:dartz/dartz.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/studio_assign.dart';
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
}
