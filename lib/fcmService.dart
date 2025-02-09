import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("📩 Background Notification Received!");

  if (message.data.isNotEmpty) {
    print('Selected Day: ${message.data['selectedDay']}');
    print('Selected Hour: ${message.data['selectedHour']}');
    //print('Message: ${message.data['message']}');
  } else {
    print('No custom data found.');
  }
}

class FCMService {

  String ?day;
  String ?hour;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Request notification permissions (for iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('🔴 Notifications are denied by the user.');
      return;
    }

    print('✅ Notifications are authorized.');

    // Get and print the FCM token
    String? fcmToken = await _firebaseMessaging.getToken();
    print("📌 FCM Token: $fcmToken");

    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground Notification Received!");
      
      if (message.data.isNotEmpty) {
        print('Selected Day: ${message.data['selectedDay']}');
        print('Selected Hour: ${message.data['selectedHour']}');
        //print('Message: ${message.data['message']}');
      } else {
        print('Not printed');
      }
    });
  }
  Future<void> sendCustomNotification(String selectedDay, String selectedHour) async {
    // Simulate sending an FCM message (in a real app, your server sends this)
    print(selectedDay);
    print(selectedHour);

    
    RemoteMessage message = RemoteMessage(
      data: {
        'selectedDay': selectedDay,
        'selectedHour': selectedHour,
        'message': 'Your booking on $selectedDay at $selectedHour is confirmed!',
      },
    );
    print('${message.data}');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if(message.notification != null) {
        print('Message contained ${message.data}');
      } else {
        print('CONTAİNED NOTHING');
      }
    });

    // Print to verify
    print("Notification Sent with Data: $message");
  }
}