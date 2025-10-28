// lib/features/profile/domain/usecases/update_profile.dart
import 'package:dartz/dartz.dart';
import 'package:swd_mobie_flutter/features/account/domain/entities/account_profile.dart';
import 'package:swd_mobie_flutter/features/account/domain/repositories/account_repository.dart';

import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';

// Usecase này trả về "void" (không có gì)
// và nhận vào tham số là "UpdateProfileParams"
class UpdateProfile implements UseCase<void, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  // Hàm call này sẽ lấy `params.profile`
  // và gửi nó cho repository
  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params.profile);
  }
}

// === ĐỊNH NGHĨA LỚP THAM SỐ ===
// Chúng ta tạo lớp này để đóng gói dữ liệu
// cần thiết cho Usecase
class UpdateProfileParams extends Equatable {
  final Profile profile; // Tham số là 1 đối tượng Profile

  const UpdateProfileParams({required this.profile});

  @override
  List<Object?> get props => [profile];
}
