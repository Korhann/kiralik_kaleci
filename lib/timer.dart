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
  static var remainingTime;

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
    // eğer pazartesi olmuşsa gün aktive ediyor
    if (DateTime.now().weekday == DateTime.monday) {
      _scheduleWeeklyRefresh();
      _startCountdown();
      // kullanıcı yenileme gününe kadar uygulamayı açmadıysa
      checkAndResetAppointments();
      // appointmentlerde silinicek
      AppointmentsPage().deleteAppointments();
    }
  }

  void _scheduleWeeklyRefresh() {
    Duration duration = _calculateTimeUntilNextMonday();
    _weeklyTimer = Timer(duration, () {
      refreshAppointments();
      _weeklyTimer = Timer.periodic(const Duration(days: 7), (timer) {
        refreshAppointments();
      });
    });
  }

  void _startCountdown() {
    // başla bir sayaç daha varsa yok edilecek
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime = _calculateTimeUntilNextMonday();
      _remainingTimeController.add(remainingTime);
      //print("Remaining time until next refresh: $remainingTime");
    });
  }

  // kulllanıcı uygulamayı pazartesi gününe kadar açmadıysa (daha kullanılmadı) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  void checkAndResetAppointments() {
  Duration remainingTime = _calculateTimeUntilNextMonday();
  if (remainingTime.isNegative) {
    // eğer kalan zaman negatif ise kendiliğinden yeniliyor
    refreshAppointments();
  }
}

  Duration _calculateTimeUntilNextMonday() {
  DateTime now = DateTime.now().toUtc().add(const Duration(hours: 3)); // Adjusting to UTC+3 for Turkey Time
  //todo: şuan cumartesi olarak ayarlı sonradan değiştirilecek
  int daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;

  DateTime nextMonday = now.add(Duration(days: daysUntilMonday)).copyWith(hour: 0, minute: 0, second: 0);
  return nextMonday.difference(now);
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
