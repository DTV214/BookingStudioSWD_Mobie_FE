// lib/features/profile/domain/repositories/profile_repository.dart

import 'package:dartz/dartz.dart';
import 'package:swd_mobie_flutter/features/account/domain/entities/account_profile.dart';

import '../../../../core/errors/failure.dart'; // Import lớp Failure chung
// Import Entity

abstract class ProfileRepository {
  // Trả về: Hoặc là 1 Lỗi (Failure), hoặc là 1 Profile (thành công)
  Future<Either<Failure, Profile>> getProfile();

  // Trả về: Hoặc là 1 Lỗi (Failure), hoặc là void (thành công, không cần dữ liệu)
  // Nhận vào 1 đối tượng Profile (entity)
  Future<Either<Failure, void>> updateProfile(Profile profile);
}
