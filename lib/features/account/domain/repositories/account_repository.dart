import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/account_profile.dart';

abstract class AccountRepository {
  // Hợp đồng 1: Lấy thông tin profile
  Future<Either<Failure, AccountProfile>> getProfile();

  // Hợp đồng 2: Cập nhật profile (chỉ 3 trường được phép)
  Future<Either<Failure, void>> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String address,
  });
}
