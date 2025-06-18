import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/firebase_options.dart';

import 'config/env.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.setEnvironment(EnvironmentType.stage);

  if (Env.useFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await initializeApp();

  runApp(const MyApp());
}
