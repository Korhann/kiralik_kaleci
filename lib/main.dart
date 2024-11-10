import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/timer.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  TimerService().startWeeklyRefresh();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    // uygulama kapanınca timeservice i de kapatıyor
    TimerService().dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}



