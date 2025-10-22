// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:swd_mobie_flutter/core/errors/failure.dart';

import '../entities/token.dart';

abstract class AuthRepository {
  // Chức năng 1: Đăng nhập bằng Google
  // Trả về Token nếu thành công, hoặc Failure nếu thất bại
  Future<Either<Failure, Token>> loginWithGoogle();

  // TODO: Sau này có thể thêm các chức năng khác
  // Future<Either<Failure, void>> logout();
  // Future<Either<Failure, User>> getCurrentUser();
}
