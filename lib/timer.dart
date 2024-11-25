import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:kiralik_kaleci/appointmentspage.dart';

class TimerService with ChangeNotifier {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;

  TimerService._internal();

  Timer? _weeklyTimer;
  Timer? _countdownTimer;
  late Duration remainingTime;

  final StreamController<Duration> _remainingTimeController = StreamController<Duration>.broadcast();
  Stream<Duration> get remainingTimeStream => _remainingTimeController.stream;

  final String? currentuser = FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _weeklyTimer?.cancel();
    _countdownTimer?.cancel();
    _remainingTimeController.close();
    super.dispose();
  }

  void startWeeklyRefresh() async{
    remainingTime = _calculateTimeUntilNextMonday();
    if (remainingTime.isNegative) {
      await _performWeeklyReset();
    } else {
      Timer(remainingTime,() async{ 
        await _performWeeklyReset();
      });
    }
  }

  Future<void> _performWeeklyReset() async{
    _scheduleWeeklyRefresh();
    _startCountdown();
    const AppointmentsPage().deleteAppointments();
  }

  void _scheduleWeeklyRefresh() {
    Duration duration = _calculateTimeUntilNextMonday();
    _weeklyTimer = Timer(duration, () {
      refreshAppointments();
    });
  }

  void _startCountdown() {
    // başla bir sayaç daha varsa yok edilecek 
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime = _calculateTimeUntilNextMonday();
      _remainingTimeController.add(remainingTime);
      print("Remaining time until next refresh: $remainingTime");
    });
  }
  /*
  // kullanıcı uygulamayı pazartesi gününe kadar açmadıysa (daha kullanılmadı) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  Future<void> checkAndResetAppointments() async{
  Duration remainingTime = _calculateTimeUntilNextMonday();
  if (remainingTime.isNegative) {
    // eğer kalan zaman negatif ise kendiliğinden yeniliyor
    refreshAppointments();
  }
}
*/

  // salı olarak deneme yapılacak
  Duration _calculateTimeUntilNextMonday() {
  DateTime now = DateTime.now().toUtc().add(const Duration(hours: 3)); // Adjusting to UTC+3 for Turkey Time
  int targetDay = DateTime.tuesday;
  int daysUntilMonday = (targetDay - now.weekday + 7) % 7;
  if (daysUntilMonday == 0 && (now.hour > 0 || now.minute > 0 || now.second > 0)) {
    daysUntilMonday = 7;
  }
  DateTime nextTargetDay = now.add(Duration(days: daysUntilMonday)).copyWith(
    hour: 0,
    minute: 0,
    second: 0
  );
  return nextTargetDay.difference(now);
}

  // pazartesi günü istaken ların hepsini false yapıyor
  void refreshAppointments() async{
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Users').doc(currentuser).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.isNotEmpty && data.containsKey('sellerDetails')) {
        Map<String, dynamic> sellerDetails = data['sellerDetails'];
        if (sellerDetails.containsKey('selectedHoursByDay')) {
          Map<String, dynamic> selectedHoursByDay = sellerDetails['selectedHoursByDay'];

          // istaken ları false yapıyor
          selectedHoursByDay.forEach((days, values) {
            if (values is List) {
              for (var props in values) {
                if (props is Map<String,dynamic> && props.containsKey('istaken')) {
                  props['istaken'] = false;
                }
              }
            }
          });
          await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentuser)
          .update({
            'sellerDetails.selectedHoursByDay': selectedHoursByDay
          });
        }
      }
    }
    print("Time now is: ${DateTime.now().toUtc().add(const Duration(hours: 3))}");
  }
}
