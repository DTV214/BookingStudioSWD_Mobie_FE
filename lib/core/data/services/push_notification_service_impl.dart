import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:swd_mobie_flutter/core/domain/services/push_notification_service.dart';

class PushNotificationServiceImpl implements PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // 1. Phương thức khởi tạo
  @override
  Future<void> initialize() async {
    // 1. Yêu cầu quyền
    await _fcm.requestPermission();

    // 2. Thiết lập xử lý thông báo background (sẽ làm sau)
    // ...
  }

  // 2. Phương thức lấy Token
  @override
  Future<String?> getFCMToken() async {
    return await _fcm.getToken();
  }

  // 3. Phương thức lắng nghe thông báo (sẽ làm sau)
  @override
  void listenToNotifications(Function(Map<String, dynamic> message) handler) {
    // Logic lắng nghe...
  }
}
