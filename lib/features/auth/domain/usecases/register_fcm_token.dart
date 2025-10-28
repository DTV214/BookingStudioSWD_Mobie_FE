import 'package:swd_mobie_flutter/features/auth/domain/repositories/auth_repository.dart';

class RegisterFCMToken {
  final AuthRepository _repository;

  RegisterFCMToken(this._repository);

  Future<void> call(String token) async {
    return _repository.registerFCMToken(token);
  }
}