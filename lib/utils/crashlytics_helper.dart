import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> reportErrorToCrashlytics(
  dynamic e,
  StackTrace stack, {
  String? reason,
  bool fatal = false,
}) async {
  await FirebaseCrashlytics.instance.recordError(
    e,
    stack,
    reason: reason,
    fatal: fatal,
  );
}