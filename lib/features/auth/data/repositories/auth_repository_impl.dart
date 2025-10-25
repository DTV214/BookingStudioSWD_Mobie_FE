// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:swd_mobie_flutter/core/errors/exceptions.dart';
import 'package:swd_mobie_flutter/core/errors/failure.dart';

import '../../domain/entities/token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

// Đây là "Triển khai" của "Hợp đồng" AuthRepository bên Domain
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  // TODO: Thêm NetworkInfo để kiểm tra mạng

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Token>> loginWithGoogle() async {
    // TODO: Kiểm tra mạng ở đây
    // if (await networkInfo.isConnected) { ... }

    try {
      // 1. Gọi Remote (Google + API)
      final remoteToken = await remoteDataSource.loginWithGoogle();

      // 2. Nếu thành công, lưu token vào local
      await localDataSource.cacheToken(remoteToken);

      // 3. Trả về kết quả "bên Phải" (Right = Success)
      return Right(remoteToken);
    } on ServerException catch (e) {
      // Dịch ServerException thành ServerFailure
      return Left(ServerFailure(e.message));
    } on GoogleSignInException catch (e) {
      // Dịch GoogleSignInException thành GoogleSignInFailure
      return Left(GoogleSignInFailure(e.message));
    } on CacheException catch (e) {
      // Dịch CacheException thành CacheFailure
      return Left(CacheFailure(e.message));
    }
  }
}
