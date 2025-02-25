import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:kiralik_kaleci/approvedfield.dart';
import 'package:kiralik_kaleci/firebase_options.dart';
import 'package:kiralik_kaleci/football_field.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/notification/push_helper.dart';
import 'package:kiralik_kaleci/paymentpage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'appointmentspage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();

  await Hive.deleteBoxFromDisk('football_fields');
  Hive.registerAdapter(FootballFieldAdapter());

  await Hive.deleteBoxFromDisk('approved_fields');
  Hive.registerAdapter(ApprovedFieldAdapter());
  
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("de08ba6c-7f05-4304-90ac-a3c3c1f6b94d");
  await PushHelper.updateOneSignal();

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.Notifications.requestPermission(true);

  setupNotificationListener();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final navigatorKey = GlobalKey<NavigatorState>();


  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      // theme: ThemeData.light(),
      // darkTheme: ThemeData.dark(),
      // home: const MainPage(),
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Kalecim',
      initialRoute: '/',
      routes: {
        '/':(context) => const MainPage(),
      },
    );
  }
}

void setupNotificationListener() {
  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;
    String? page = data?['page'];


    if (page != null) {
      BuildContext? context = MyApp.navigatorKey.currentContext;

      if (context != null) {
        switch (page) {
          case "payment":
            if (ModalRoute.of(context)?.settings.name != "/paymentPage") {
              String sellerUid = data?['sellerUid'] ?? '';
              String selectedDay = data?['selectedDay'] ?? '';
              String selectedHour = data?['selectedHour'] ?? '';
              String selectedField = data?['selectedField'] ?? '';
              String docId = data?['docId'] ?? '';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentPage(
                    sellerUid: sellerUid,
                    selectedDay: selectedDay,
                    selectedHour: selectedHour,
                    selectedField: selectedField,
                    docId: docId,
                  ),
                ),
              );
            }
            break;
          case "appointment":
            if (ModalRoute.of(context)?.settings.name != "/appointmentsPage") {
              // alıcı sayfasında çağırınca alıcı olarak algılıyor
              userorseller = true;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentsPage()
                )
              );
            }
            break;
          default:
            print("Unknown page: $page");
            break;
        }
      }
    }
  });
}

