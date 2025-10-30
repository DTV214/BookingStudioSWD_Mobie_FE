import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:swd_mobie_flutter/core/domain/services/push_notification_service.dart';
import 'package:swd_mobie_flutter/features/booking/domain/usecases/get_booking_detail_usecase.dart';
import 'package:swd_mobie_flutter/main.dart';

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
  final GetBookingDetailUsecase getBookingDetailUsecase;

  PushNotificationServiceImpl({
    required this.getBookingDetailUsecase,
  });

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

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveLocalNotification,
    );

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

  /// Showing Notification Handle for Foreground Message
  void _handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          // Notification Id
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: android.smallIcon,
            ),
          ),
          // Payload: Save Data for Clicking Notification Handle
          payload: json.encode(message.data),
        );
      }
    });
  }

  /// Clicking Notification Handle Remote Message (Background and Terminated)
  Future<void> _setupInteractedMessage() async {
    // Case 01: Terminated State
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Case 02: Background State
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  /// Extract Payload from Message and Redirect Page
  void _handleMessage(RemoteMessage message) {
    // 1. Extract Payload
    final String screen = message.data['screen'] ?? '';
    final String bookingId = message.data['booking_id'] ?? '';

    print('Payload received. Navigating to: $screen with ID: $bookingId');

    // 2. Redirect Page
    _navigateToDetail(screen, bookingId);
  }

  /// Navigate screen detail by using main.dart Global Navigate
  void _navigateToDetail(String screen, String entityId) async {
    if (screen == 'booking_detail') {
      final result = await getBookingDetailUsecase(entityId);

      result.fold(
              (failure) {
            // Handle Fail
          },
              (booking) {
            // Handle Success
            if (navigatorKey.currentState != null) {
              navigatorKey.currentState!.pushNamed(
                '/booking_detail',
                arguments: booking,
              );
            }
          }
      );
    }
  }

  /// Clicking Notification Handle for Foreground Message
  void onDidReceiveLocalNotification(
      NotificationResponse notificationResponse,) async {
    if (notificationResponse.payload != null) {
      try {
        // 1. Parse JSON string
        final Map<String, dynamic> data = json.decode(
          notificationResponse.payload!,
        );

        final String screen = data['screen'] ?? '';
        final String bookingId = data['booking_id'] ?? '';

        print(
          'Local Notification clicked. Navigating to: $screen with ID: $bookingId',
        );

        // 2. Redirect Page
        _navigateToDetail(screen, bookingId);
      } catch (e) {
        print('Lỗi parsing payload JSON: $e');
      }
    }
  }
}
