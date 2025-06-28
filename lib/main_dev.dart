import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/env.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.setEnvironment(EnvironmentType.dev);

  if (Env.useFirebase) {
    if (Firebase.apps.isEmpty){
      await Firebase.initializeApp(
        name: 'KiralikKaleci-dev',
        options: DefaultFirebaseOptions.currentPlatform,
    );
    }
  }

  await initializeApp();
  String? userType = await getUserType();

  // runApp(MyApp(userType: userType));
  runApp(DevicePreview(builder: (context) => MyApp(userType: userType), enabled: !kReleaseMode));
}

Future<String?> getUserType() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userType'); // Retrieve user type
} 