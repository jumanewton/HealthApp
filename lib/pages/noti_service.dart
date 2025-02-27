import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Intialize the notification service
  Future<void> initNotification() async {
    if (_isInitialized)
      return; // if already initialized, prevent re-initialization
    // prepare android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // prepare the ios settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    // prepare the initialization settings
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    // initialize the notification plugin
    await notificationsPlugin.initialize(initializationSettings);
    // _isInitialized = true;
  }

  // Notification Detail Setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('health_id', 'Health Tips',
            channelDescription: 'Daily Health Tips',
            importance: Importance.max,
            priority: Priority.high),
        iOS: DarwinNotificationDetails());
  }

  // Show Notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return notificationsPlugin.show(
        id, title, body, const NotificationDetails());
  }
}
