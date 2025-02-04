import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // initalize
  Future<void> initNotification() async {
    if (_isInitialized) return;
    const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettingsIos = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true
    );
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIos
    );

    await notificationsPlugin.initialize(initSettings);
  }
  // notificaiton details
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Randevu Hatırlatması',
        importance: Importance.max,
        priority: Priority.high
      ),
      iOS: DarwinNotificationDetails()
    );
  }
  // show notifications
  Future<void> showNotification(int id,String title,String body) async {
    return notificationsPlugin.show(id, title, body, const NotificationDetails());
  }
}