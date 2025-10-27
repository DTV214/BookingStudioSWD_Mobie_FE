// lib/features/profile/domain/usecases/get_profile.dart
import 'package:dartz/dartz.dart';
import 'package:swd_mobie_flutter/features/account/domain/entities/account_profile.dart';
import 'package:swd_mobie_flutter/features/account/domain/repositories/account_repository.dart';

import '../../../../core/errors/failure.dart';
// Import Usecase cơ bản (bạn đã có)
import '../../../../core/usecase/usecase.dart';

// Usecase này sẽ "triển khai" hợp đồng UseCase
// Nó trả về 1 "Profile" và không cần tham số "NoParams"
class GetProfile implements UseCase<Profile, NoParams> {
  // Nó phụ thuộc vào "hợp đồng" Repository,
  // không phải "triển khai" RepositoryImpl
  final ProfileRepository repository;

  GetProfile(this.repository);

  // Đây là hàm duy nhất mà lớp Usecase có
  // Nó chỉ đơn giản là gọi hàm tương ứng từ Repository
  @override
  Future<Either<Failure, Profile>> call(NoParams params) async {
    return await repository.getProfile();
  }
}
