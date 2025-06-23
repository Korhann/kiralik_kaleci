import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kiralik_kaleci/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kiralik_kaleci/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Firebase before any Firebase usage
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  testWidgets('sign up user', (tester) async {
    await tester.pumpWidget(MyApp(userType: 'user'));
    await tester.pumpAndSettle();

    // Go to sign up page
    await tester.tap(find.text('Kayıt Ol'));
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
    print('SIGN UP SUCCESSFUL');
  });

  testWidgets('search page loads and displays results or empty state', (tester) async {
    await tester.pumpWidget(MyApp(userType: 'user'));
    await tester.pumpAndSettle();

    // Expect the search page title
    expect(find.text('Kalecilerimiz'), findsOneWidget);

    // Wait for possible loading
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Check for either results or empty state
    final emptyStateFinder = find.text('İlgili sonuç bulunamadı');
    final sellerGridFinder = find.byType(GridView);

    expect(
      emptyStateFinder.evaluate().isNotEmpty || sellerGridFinder.evaluate().isNotEmpty,
      true,
      reason: 'Should show either empty state or seller grid',
    );

    print('SEARCH PAGE TEST SUCCESSFUL');
  });
}

/*
flutter drive --flavor dev --target=integration_test/app_test.dart --driver=integration_test/test_driver.dart
*/