// lib/features/auth/domain/usecases/login_with_google.dart
import 'package:dartz/dartz.dart';
import 'package:swd_mobie_flutter/core/errors/failure.dart';
import 'package:swd_mobie_flutter/core/usecase/usecase.dart';

import '../entities/token.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogle implements UseCase<Token, NoParams> {
  final AuthRepository repository;

  // Tiêm (inject) repository vào
  LoginWithGoogle(this.repository);

  @override
  Future<Either<Failure, Token>> call(NoParams params) async {
    // Chỉ cần gọi hàm từ repository
    return await repository.loginWithGoogle();
  }
}
