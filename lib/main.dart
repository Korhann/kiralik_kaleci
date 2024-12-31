import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/timer.dart';
import 'package:workmanager/workmanager.dart';
import 'appointmentspage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize WorkManager
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true
  );

  // Register the periodic task
  const taskName = 'refreshAppointments';
  //Workmanager().cancelByUniqueName(taskName); // Clear previous tasks to avoid conflicts
  await Workmanager().registerPeriodicTask(
    taskName,
    taskName,
    frequency: const Duration(minutes: 15), // Test interval
    initialDelay: Duration(seconds: 10),
  );

  runApp(const MyApp());
}

// Bunu bir daha dene ve neyi ekleyince çalıştığını anla !!!
@pragma('vm:entry-point')
void callbackDispatcher() async{
  Workmanager().executeTask((task, inputData) async {
    // Initialize Firebase for the background isolate
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print("Firebase initialization failed: $e");
      return Future.value(false);
    }
    DateTime now = DateTime.now().toUtc().add(const Duration(hours: 3)); // Adjust to UTC+3 for Turkey
    try {
      if (now.weekday == DateTime.tuesday) {
      TimerService timerService = TimerService();
      AppointmentsPage appointmentsPage = AppointmentsPage();

      // seçili olan saatleri ve randevuları yenileyecek
      await timerService.performWeeklyReset();
      await appointmentsPage.deleteAppointments();
      print('Periodic task executed: $task at $now');
      } else {
      print('Not monday!!');
      }
    } catch (e) {
      print('Error code days $e');
    }

    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
