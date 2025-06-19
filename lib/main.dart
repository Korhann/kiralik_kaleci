import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:kiralik_kaleci/approvedfield.dart';
import 'package:kiralik_kaleci/firebase_options.dart';
import 'package:kiralik_kaleci/football_field.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/loginpage.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/notification/push_helper.dart';
import 'package:kiralik_kaleci/paymentpage.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'appointmentspage.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//   ]);
//   await Hive.initFlutter();

//   await Hive.deleteBoxFromDisk('football_fields');
//   Hive.registerAdapter(FootballFieldAdapter());

//   await Hive.deleteBoxFromDisk('approved_fields');
//   Hive.registerAdapter(ApprovedFieldAdapter());
  
//   OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//   OneSignal.initialize("de08ba6c-7f05-4304-90ac-a3c3c1f6b94d");
//   await PushHelper.updateOneSignal();

//   // firebase crashlytics
//   FlutterError.onError = (errorDetails) {
//     FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
//     FirebaseCrashlytics.instance.setUserIdentifier(FirebaseAuth.instance.currentUser?.uid ?? 'anonymous');
//   };

//   // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
//   PlatformDispatcher.instance.onError = (error, stack) {
//     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
//     return true;
//   };

//   // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
//   OneSignal.Notifications.requestPermission(true);

//   setupNotificationListener();
//   String? userType = await getUserType();
  
//   runApp(MyApp(userType: userType));
// }

// Future<String?> getUserType() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('userType'); // Retrieve user type
// }



// class MyApp extends StatelessWidget {
//   final String? userType;

//   const MyApp({super.key, required this.userType});
//   static final navigatorKey = GlobalKey<NavigatorState>();

//   @override
//   Widget build(BuildContext context) {
//     return PlatformApp(
//     // locale: DevicePreview.locale(context),
//     // builder: DevicePreview.appBuilder,
//     // theme: ThemeData.light(),
//     // darkTheme: ThemeData.dark(),
//     // home: const MainPage(),
//     debugShowCheckedModeBanner: false,
//     navigatorKey: navigatorKey,
//     title: 'Kalecim',
//     initialRoute: '/',
//     home:  userType == 'seller' ? SellerMainPage(index: 2) : userType == 'user' ? MainPage(index: 2) : LogIn(),
//     // routes: {
//     //   '/':(context) => MainPage(index: 2),
//     // },
//     );
//   }
// }

// void setupNotificationListener() {
//   OneSignal.Notifications.addClickListener((event) {
//     final data = event.notification.additionalData;
//     String? page = data?['page'];


//     if (page != null) {
//       BuildContext? context = MyApp.navigatorKey.currentContext;

//       if (context != null) {
//         switch (page) {
//           case "payment":
//             if (ModalRoute.of(context)?.settings.name != "/paymentPage") {
//               String sellerUid = data?['sellerUid'] ?? '';
//               String buyerUid = data?['buyerUid'] ?? '';
//               String selectedDay = data?['selectedDay'] ?? '';
//               String selectedHour = data?['selectedHour'] ?? '';
//               String selectedField = data?['selectedField'] ?? '';
//               String sellerDocId = data?['sellerDocId'] ?? '';
//               String buyerDocId = data?['buyerDocId'] ?? '';

//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => PaymentPage(
//                     sellerUid: sellerUid,
//                     buyerUid: buyerUid,
//                     selectedDay: selectedDay,
//                     selectedHour: selectedHour,
//                     selectedField: selectedField,
//                     sellerDocId: sellerDocId,
//                     buyerDocId: buyerDocId,
//                   ),
//                 ),
//               );
//             }
//             break;
//           case "appointment":
//             if (ModalRoute.of(context)?.settings.name != "/appointmentsPage") {
//               // alıcı sayfasında çağırınca alıcı olarak algılıyor
//               userorseller = true;
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => AppointmentsPage(whereFrom: 'fromNoti')
//                 )
//               );
//             }
//             break;
//           default:
//             print("Unknown page: $page");
//             break;
//         }
//       }
//     }
//   });
// }


const String currentFlavor = String.fromEnvironment('FLAVOR');

Future<void> initializeApp() async {
  if (kDebugMode) {
    print('Initializing app with FLAVOR: $currentFlavor');
  }
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // hive football fields
  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk('football_fields');
  Hive.registerAdapter(FootballFieldAdapter());
  await Hive.deleteBoxFromDisk('approved_fields');
  Hive.registerAdapter(ApprovedFieldAdapter());

  // onesignal push notifier
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("de08ba6c-7f05-4304-90ac-a3c3c1f6b94d");
  await PushHelper.updateOneSignal();

  // firebase crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    FirebaseCrashlytics.instance.setUserIdentifier(FirebaseAuth.instance.currentUser?.uid ?? 'anonymous');
  };

  //Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  OneSignal.Notifications.requestPermission(true);

  setupNotificationListener();
  String? userType = await getUserType();
  runApp(MyApp(userType: userType));
}

Future<String?> getUserType() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userType'); // Retrieve user type
} 



class MyApp extends StatelessWidget {
  final String? userType;
  const MyApp({super.key, required this.userType});
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
      // routes: {
      //   '/':(context) => const MainPage(),
      // },
      home:  userType == 'seller' ? SellerMainPage(index: 2) : userType == 'user' ? MainPage(index: 2) : LogIn(),
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
              String buyerUid = data?['buyerUid'] ?? '';
              String selectedDay = data?['selectedDay'] ?? '';
              String selectedHour = data?['selectedHour'] ?? '';
              String selectedField = data?['selectedField'] ?? '';
              String sellerDocId = data?['sellerDocId'] ?? '';
              String buyerDocId = data?['buyerDocId'] ?? '';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentPage(
                    sellerUid: sellerUid,
                    buyerUid: buyerUid,
                    selectedDay: selectedDay,
                    selectedHour: selectedHour,
                    selectedField: selectedField,
                    sellerDocId: sellerDocId,
                    buyerDocId: buyerDocId,
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
                  builder: (context) => AppointmentsPage(whereFrom: 'fromNoti')
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


