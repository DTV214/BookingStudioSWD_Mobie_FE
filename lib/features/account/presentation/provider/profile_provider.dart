// lib/features/profile/presentation/provider/profile_provider.dart
import 'package:flutter/material.dart';
import 'package:swd_mobie_flutter/features/account/domain/entities/account_profile.dart';

import '../../../../core/usecase/usecase.dart'; // Import NoParams

import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';

// 1. Định nghĩa các trạng thái cho UI
enum ProfileState { initial, loading, loaded, error }

class ProfileProvider extends ChangeNotifier {
  // 2. Các Usecases mà Provider này cần
  final GetProfile getProfile;
  final UpdateProfile updateProfile;

  // 3. Hàm khởi tạo, yêu cầu 2 usecases
  ProfileProvider({required this.getProfile, required this.updateProfile});

  // 4. Các biến trạng thái "nội bộ"
  ProfileState _state = ProfileState.initial;
  Profile? _profile; // Dữ liệu profile, có thể null
  String _errorMessage = '';

  // 5. Các "getter" để UI có thể đọc trạng thái
  ProfileState get state => _state;
  Profile? get profile => _profile;
  String get errorMessage => _errorMessage;

  // === 6. HÀM CHÍNH: LẤY PROFILE ===
  // (Sẽ được gọi từ SettingsPage)
  Future<void> fetchProfile() async {
    print("[ProfileProvider] Đang fetch profile...");
    // Đổi trạng thái -> Loading
    _state = ProfileState.loading;
    notifyListeners(); // Báo UI "vẽ lại" (hiện vòng xoay)

    // Gọi Usecase (Không cần tham số)
    final result = await getProfile(NoParams());

    // Xử lý kết quả (Either)
    result.fold(
      // Bên trái (Left) = Lỗi
      (failure) {
        print("[ProfileProvider] Lỗi: ${failure.message}");
        _errorMessage = failure.message;
        _state = ProfileState.error;
      },
      // Bên phải (Right) = Thành công
      (profileData) {
        print(
          "[ProfileProvider] Lấy profile thành công: ${profileData.fullName}",
        );
        _profile = profileData; // Lưu dữ liệu
        _state = ProfileState.loaded;
      },
    );

    // Báo UI "vẽ lại" (hiện dữ liệu hoặc lỗi)
    notifyListeners();
  }

  // === 7. HÀM CHÍNH: CẬP NHẬT PROFILE ===
  // (Sẽ được gọi từ EditProfilePage)
  // Trả về bool để báo cho UI biết có thành công hay không
  Future<bool> saveProfile(Profile updatedProfile) async {
    print("[ProfileProvider] Đang save profile...");
    _state = ProfileState.loading;
    notifyListeners();

    // Gọi Usecase (với tham số)
    final result = await updateProfile(
      UpdateProfileParams(profile: updatedProfile),
    );

    bool isSuccess = false; // Biến cờ

    result.fold(
      // Bên trái (Left) = Lỗi
      (failure) {
        print("[ProfileProvider] Lỗi update: ${failure.message}");
        _errorMessage = failure.message;
        _state = ProfileState.error; // Về trạng thái lỗi
        isSuccess = false;
      },
      // Bên phải (Right) = Thành công
      (success) {
        print("[ProfileProvider] Update thành công!");
        // Cập nhật lại profile trong provider
        _profile = updatedProfile;
        _state = ProfileState.loaded; // Về trạng thái đã tải
        isSuccess = true;
      },
    );

    notifyListeners();
    return isSuccess; // Trả về true/false
  }
}
