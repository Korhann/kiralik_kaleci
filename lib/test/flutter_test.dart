import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiralik_kaleci/firebase_options.dart';
import 'package:kiralik_kaleci/loginpage.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/searchpage.dart';
import 'package:kiralik_kaleci/signuppage.dart';
import 'package:kiralik_kaleci/test/mock_firebase.dart';
import 'package:mockito/mockito.dart';


void main() {

  setupFirebaseAuthMocks();
  setUpAll(() async{
    await Firebase.initializeApp();
  });
  testWidgets('Main page tester', (tester) async {
    await tester.pumpWidget(MaterialApp(home: GetUserData()));
     await tester.pumpAndSettle();
    final finder = find.text('Kalecilerimiz');
    await tester.pump();
    print('DONE');
    expect(finder, findsOneWidget);
  });
}