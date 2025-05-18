import 'package:firebase_analytics/firebase_analytics.dart';

class Firebaseanalytics {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> firebasePaymentNotification(String userId, String sellerId) async{
    await analytics.logEvent(
    name: "payment",
    parameters: {
        "buyer": userId,
        "keeper": sellerId,
    },
);
  }
}