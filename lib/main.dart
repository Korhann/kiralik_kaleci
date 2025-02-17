import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:kiralik_kaleci/approvedfield.dart';
import 'package:kiralik_kaleci/football_field.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/notification/push_helper.dart';
import 'package:kiralik_kaleci/paymentpage.dart';
import 'package:kiralik_kaleci/selleribanpage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'appointmentspage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Hive.deleteBoxFromDisk('football_fields');
  Hive.registerAdapter(FootballFieldAdapter());

  await Hive.deleteBoxFromDisk('approved_fields');
  Hive.registerAdapter(ApprovedFieldAdapter());

  await Firebase.initializeApp();
  
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("de08ba6c-7f05-4304-90ac-a3c3c1f6b94d");
  await PushHelper.updateOneSignal();

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.Notifications.requestPermission(true);

  setupNotificationListener();

  // // Initialize WorkManager
  // await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  // // todo: this works every 15 mins instead of one day
  // const taskName = 'refreshAppointments';
  // Workmanager().cancelByUniqueName(taskName); // Clear previous tasks to avoid conflicts
  // await Workmanager().registerPeriodicTask(
  //   taskName,
  //   taskName,
  //   frequency: const Duration(days: 1), // Test interval
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final navigatorKey = GlobalKey<NavigatorState>();


  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
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
          //TODO: kullanıcı sayfasına da atabiliyor
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




// // Bunu bir daha dene ve neyi ekleyince çalıştığını anla !!!
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       await Firebase.initializeApp(); // Ensure Firebase is initialized in the background

//       if (task == 'refreshAppointments') {
//         print('1');
//         await _handleRefreshAppointments();
//       } else if (task == 'checkStatus') {
//         print('2');
//         await _handleTakeAppointment(inputData);
//       } else {
//         print('Unknown task: $task');
//       }
//     } catch (e) {
//       print('Error in background task: $e');
//     }
//     return Future.value(true);
//   });
// }

// Future<void> _handleTakeAppointment(Map<String, dynamic>? inputData) async {
//   try {
//     if (inputData == null) {
//       print("No input data provided for task.");
//       return;
//     }

//     final FirebaseFirestore firestore = FirebaseFirestore.instance;
//     String sellerUid = inputData['sellerUid'];
//     String selectedDay = inputData['selectedDay'];
//     String selectedHour = inputData['selectedHour'];
//     String currentUser = inputData['currentUser'];

//     // Check appointment status
//     DocumentSnapshot statusDoc = await firestore
//         .collection('Users')
//         .doc(sellerUid)
//         .collection('appointmentseller')
//         .where('appointmentDetails.buyerUid', isEqualTo: currentUser)
//         .where('appointmentDetails.day', isEqualTo: selectedDay)
//         .where('appointmentDetails.hour', isEqualTo: selectedHour)
//         .limit(1)
//         .get()
//         .then((snapshot) => snapshot.docs.first);

//     if (statusDoc.exists) {
//       String status = statusDoc['appointmentDetails']['status'];
//       if (status == 'approved') {
//         print('APPROVED');
//         // Mark hour as taken
//         await firestore.collection("Users").doc(sellerUid).update({
//           'sellerDetails.selectedHoursByDay.$selectedDay':
//               FieldValue.arrayUnion([
//             {'title': selectedHour, 'istaken': true}
//           ])
//         });

//         // ÖDEME BURADA ALINACAK
//         bool paymentSuccessful = true; // Ödeme sistemi ile değiştir
//         if (paymentSuccessful) {
//           print(selectedDay);
//           print(selectedHour);
//           print(currentUser);
//           // TODO: BİLDİRİM GÖNDER selectedDay, selectedHour, selectedField
//           String text ='$selectedDay $selectedHour';
//           PushHelper.sendPushBefore(userId: currentUser, text: text); // burada bildirim gönderiliyor

//           print('Payment successful!');
//         }
//       } else {
//         print('Appointment is still pending.');
//       }
//     }
//   } catch (e) {
//     print('Error processing appointment: $e');
//   }
// }

// Future<void> _handleRefreshAppointments() async {
//   try {
//     DateTime now = DateTime.now()
//         .toUtc()
//         .add(const Duration(hours: 3)); // UTC+3 for Turkey

//     if (now.weekday == DateTime.tuesday) {
//       TimerService timerService = TimerService();
//       AppointmentsPage appointmentsPage = AppointmentsPage();

//       // Refresh all time slots and delete old appointments
//       // await timerService.performWeeklyReset();
//       // await appointmentsPage.deleteAppointments();

//       print('Appointments refreshed successfully.');
//     } else {
//       print('Not Tuesday, skipping refresh.');
//     }
//   } catch (e) {
//     print('Error refreshing appointments: $e');
//   }
// }
