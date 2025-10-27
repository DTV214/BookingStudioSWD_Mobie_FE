abstract class PushNotificationService {
  Future<void> initialize();
  Future<String?> getFCMToken();
  void listenToNotifications(Function(Map<String, dynamic> message) handler);
}