// lib/features/auth/presentation/provider/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:swd_mobie_flutter/core/domain/services/push_notification_service.dart';
import 'package:swd_mobie_flutter/core/usecase/usecase.dart';
import 'package:swd_mobie_flutter/features/auth/domain/usecases/register_fcm_token.dart';

import '../../domain/entities/token.dart';
import '../../domain/usecases/login_with_google.dart';

// 1. Định nghĩa các trạng thái
enum AuthState { initial, loading, authenticated, error }

class AuthProvider extends ChangeNotifier {
  final LoginWithGoogle loginWithGoogleUseCase;
  final RegisterFCMToken registerFCMTokenUseCase;
  final PushNotificationService pushNotificationService;

  // TODO: Thêm Usecase check login status và logout

  // 2. Các biến trạng thái
  AuthState _state = AuthState.initial;

  AuthState get state => _state;

  Token? _token;

  Token? get token => _token;

  String _errorMessage = '';

  String get errorMessage => _errorMessage;

  // 3. Hàm khởi tạo
  AuthProvider({
    required this.loginWithGoogleUseCase,
    required this.registerFCMTokenUseCase,
    required this.pushNotificationService,
  }) {
    // TODO: Khi khởi tạo, nên kiểm tra xem đã login chưa
    // checkLoginStatus();
  }

  // 4. Hàm chính để thực hiện login
  Future<void> login() async {
    // Đổi trạng thái -> Loading
    _state = AuthState.loading;
    notifyListeners(); // Báo cho UI "vẽ lại" (hiện vòng xoay)

    // Gọi Usecase
    final result = await loginWithGoogleUseCase(NoParams());

    // Xử lý kết quả
    result.fold(
      // Bên trái (Left) = Lỗi
      (failure) {
        _errorMessage = failure.message;
        _state = AuthState.error;
        notifyListeners(); // Báo cho UI "vẽ lại" (hiện lỗi)
      },
      // Bên phải (Right) = Thành công
      (token) async {
        _token = token;
        _state = AuthState.authenticated;

        // ---> LOGIC PUSH NOTIFICATION <---

        // 1. Khởi tạo service (yêu cầu quyền)
        await pushNotificationService.initialize();

        // 2. Lấy Token
        final fcmToken = await pushNotificationService.getFCMToken();

        // 3. Nếu Token có, đăng ký nó với Spring Boot API
        if (fcmToken != null) {
          // GỌI USECASE ĐỂ GỬI LÊN SERVER
          await registerFCMTokenUseCase(fcmToken);
        }

        // ------------------------------------------------

        notifyListeners(); // Báo cho UI "vẽ lại" (chuyển trang)
      },
    );
  }

  // TODO: Thêm hàm logout
  // Future<void> logout() async { ... }
}
