// lib/features/profile/data/repositories/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:swd_mobie_flutter/features/account/data/datasources/account_remote_data_source.dart';
import 'package:swd_mobie_flutter/features/account/data/models/account_profile_model.dart';
import 'package:swd_mobie_flutter/features/account/domain/entities/account_profile.dart';
import 'package:swd_mobie_flutter/features/account/domain/repositories/account_repository.dart';
import '../../../../core/errors/exceptions.dart'; // Import các Exception
import '../../../../core/errors/failure.dart'; // Import các Failure
// Import Model

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  // TODO: Thêm NetworkInfo nếu bạn muốn kiểm tra kết nối mạng

  ProfileRepositoryImpl({required this.remoteDataSource});

  // === 1. TRIỂN KHAI HÀM GET PROFILE ===
  @override
  Future<Either<Failure, Profile>> getProfile() async {
    // TODO: Kiểm tra kết nối mạng ở đây
    try {
      // Gọi remoteDataSource (đã tạo ở bước 3)
      final remoteProfile = await remoteDataSource.getProfile();

      // remoteProfile là một ProfileModel, nhưng vì nó "extends Profile",
      // chúng ta có thể trả về nó trực tiếp.
      // Right = Thành công
      return Right(remoteProfile);
    } on ServerException catch (e) {
      // Dịch ServerException thành ServerFailure
      // Left = Thất bại
      return Left(ServerFailure(e.message ?? 'Lỗi máy chủ'));
    } on CacheException catch (e) {
      // Dịch CacheException (lỗi không tìm thấy token) thành CacheFailure
      return Left(CacheFailure(e.message ?? 'Lỗi bộ nhớ đệm'));
    }
  }

  // === 2. TRIỂN KHAI HÀM UPDATE PROFILE ===
  @override
  Future<Either<Failure, void>> updateProfile(Profile profile) async {
    // TODO: Kiểm tra kết nối mạng ở đây
    try {
      // **Quan trọng**: Hàm này nhận vào 1 `Profile` (Entity).
      // Nhưng `remoteDataSource` cần 1 `ProfileModel` (Model)
      // Chúng ta phải "biến hình" nó.
      final profileModel = ProfileModel(
        id: profile.id,
        fullName: profile.fullName,
        email: profile.email,
        phoneNumber: profile.phoneNumber,
        accountRole: profile.accountRole,
        userType: profile.userType,
        avatarUrl: profile.avatarUrl,
      );

      // Gọi remoteDataSource với ProfileModel
      await remoteDataSource.updateProfile(profileModel);

      // Thành công, trả về Right(null) vì hàm là Future<void>
      return Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Lỗi máy chủ'));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message ?? 'Lỗi bộ nhớ đệm'));
    }
  }
}
