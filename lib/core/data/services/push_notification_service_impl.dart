import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:swd_mobie_flutter/core/domain/services/push_notification_service.dart';

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Channel Definition
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'booking_studio_channel',
  'Booking Notification',
  description: 'Notify new booking',
  importance: Importance.high,
);

class PushNotificationServiceImpl implements PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Init Local Notification (Foreground) And Its Handler, Channel for Android
  @override
  Future<void> initialize() async {
    // 1. Yêu cầu quyền
    await _fcm.requestPermission();

    // 2. Khởi tạo Local Notifications cho cả Android/iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 3. Tạo Channel cho Android (Cần thiết cho Android 8.0+)
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // 4. Thiết lập xử lý tin nhắn Foreground
    _setupInteractedMessage();
    _handleForegroundMessages();
  }

  /// Get FCM Token
  @override
  Future<String?> getFCMToken() async {
    return await _fcm.getToken();
  }

  // 3. Phương thức lắng nghe thông báo (sẽ làm sau)
  @override
  void listenToNotifications(Function(Map<String, dynamic> message) handler) {
    // Logic lắng nghe...
  }

  // Xử lý tin nhắn khi app đang chạy (Foreground)
  void _handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        // Tự tạo và hiển thị thông báo Local
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode, // ID thông báo
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              // PHẢI SỬ DỤNG CHÍNH XÁC ID CỦA CHANNEL ĐÃ TẠO Ở TRÊN
              _channel.name,
              channelDescription: _channel.description,
              icon: android.smallIcon,
            ),
          ),
          // Payload: Lưu trữ data để xử lý khi người dùng nhấn vào thông báo này
          payload: message.data['screen'] ?? '',
        );
      }
    });
  }

  // Xử lý khi người dùng nhấn vào thông báo
  // (Background và Terminated)
  Future<void> _setupInteractedMessage() async {
    // Trường hợp 1: Mở ứng dụng từ Terminated state (Đã đóng hoàn toàn)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      // Logic xử lý khi mở từ Terminated state (ví dụ: chuyển trang)
      // _handleMessage(initialMessage);
    }

    // Trường hợp 2: Khi người dùng nhấn vào thông báo (từ Background state)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Logic xử lý khi mở từ Background state (ví dụ: chuyển trang)
      // _handleMessage(message);
    });
  }
}
