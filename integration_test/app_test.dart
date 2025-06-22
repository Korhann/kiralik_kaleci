import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kiralik_kaleci/main.dart';
import 'package:kiralik_kaleci/main.dart' as Firebase;

/*
flutter drive --flavor dev --target=integration_test/app_test.dart --driver=integration_test/test_driver.dart
flutter drive --flavor prod --target=integration_test/app_test.dart --driver=integration_test/test_driver.dart
flutter drive --flavor stage --target=integration_test/app_test.dart --driver=integration_test/test_driver.dart
*/


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign up integration test', (tester) async {
    await tester.pumpWidget(MyApp(userType: 'user'));

    // Navigate to SignUp page
    await tester.tap(find.text('Kayıt Ol')); // Adjust if you use a different navigation
    await tester.pumpAndSettle();

    // Fill the sign up form with unique email
    final random = Random().nextInt(100000);
    final testEmail = 'testuser$random@example.com';

    await tester.enterText(find.byKey(const Key('signup_name')), 'Test User');
    await tester.enterText(find.byKey(const Key('signup_email')), testEmail);
    await tester.enterText(find.byKey(const Key('signup_phone')), '5555555555');
    await tester.enterText(find.byKey(const Key('signup_password')), 'password123');
    await tester.enterText(find.byKey(const Key('signup_password_again')), 'password123');

    // Tap the sign up button
    await tester.tap(find.byKey(const Key('signup_button')));
    await tester.pumpAndSettle();

    // Check for a widget/text that appears after successful sign up
    expect(find.text('Kalecilerimiz'), findsOneWidget);
  });
}