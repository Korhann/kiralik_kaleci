
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/notification/push_helper.dart';
import 'package:kiralik_kaleci/notification_model.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ApptRequest extends StatefulWidget {
  final String sellerUid;
  final String selectedDay;
  final String selectedHour;
  final String selectedField;
  final int selectedPrice;

  const ApptRequest({
    super.key,
    required this.sellerUid,
    required this.selectedDay,
    required this.selectedHour,
    required this.selectedField,
    required this.selectedPrice
  });

  @override
  State<ApptRequest> createState() => _ApptRequestState();
}

class _ApptRequestState extends State<ApptRequest> {

  // referanslar
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;
  late String sellerFullName;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
        }, icon: const Icon(Icons.arrow_back, color: Colors.black)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      'Seçilen gün ve saat',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Row(
                        children: [
                          _selectedDay(),
                          const Spacer(),
                          _selectedHour()
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Seçilen saha',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: _selectedField(),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Ödenecek Tutar',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Row(
                        children: [
                          Text(
                            'Hizmet Bedeli:',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: Colors.black
                              ),
                          ),
                          const Spacer(),
                          _price()
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                // check for the internet connection
                onPressed: () async{
                  if (await InternetConnection().hasInternetAccess) {
                    await sendRequest();
                    await navigateToHomePage();
                  } else {
                    if (mounted) {
                      Showalert(context: context, text: 'Ooops...').showErrorAlert();
                    }
                  }
                }, 
              style: GlobalStyles.buttonPrimary(),
              child: Text(
                'Randevu Talebi Gönder',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                )
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> navigateToHomePage() async{
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const MainPage(index: 0))
    );
    }
  }

  Widget _selectedField() {
    return Text(
      widget.selectedField,
      style: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    );
  }

  Widget _selectedDay() {
  return Text(
    widget.selectedDay,
    style: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
  );
}
  Widget _selectedHour() {
  return Text(
    widget.selectedHour,
    style: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
  );
}

  Widget _price() {
    return Text(
          '${widget.selectedPrice}TL',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: Colors.black
          ),
        );
  }

  Future<void> markHourAsTaken(String day, String hourTitle) async {
    DocumentReference userRef = FirebaseFirestore.instance.collection("Users").doc(widget.sellerUid);

    // Get the existing document
    DocumentSnapshot snapshot = await userRef.get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.containsKey('sellerDetails')) {
        Map<String, dynamic> sellerDetails = data['sellerDetails'];
        if (sellerDetails.containsKey('selectedHoursByDay')) {
          Map<String, dynamic> selectedHoursByDay = sellerDetails['selectedHoursByDay'];
          if (selectedHoursByDay.containsKey(day)) {
            List<dynamic> hours = selectedHoursByDay[day];
            for (int i = 0; i < hours.length; i++) {
              // ÖRNEĞİN PAZARTESİ İÇİN SEÇENEK 3 SAAT VARSA SEÇİLEN HANGİSİ DİYE BAKIYOR
              Map<String, dynamic> hour = hours[i];
              if (hour['title'] == hourTitle) {
                // Mark the hour as taken
                hour['istaken'] = true;
                // Update Firestore with the new data
                selectedHoursByDay[day] = hours;
                await userRef.update({
                  'sellerDetails.selectedHoursByDay': selectedHoursByDay
                });
                break;
              }
            }
          }
        }
      }
    }
  }

  // // ÖDEME BURAYA EKLENECEK
  // Future<bool> _processPayment() async {

  //   // Simulate payment process (replace this with actual payment gateway logic)
  //   await Future.delayed(const Duration(seconds: 2));
  //   return true; // Return true if payment is successful
  // }

  // burada eğer approved olursa eklenecek
  Future<String> appointmentBuyer(String verificationCode, String startTime, String endTime) async{
    try {
      final snapshot = await _firestore.collection('Users').doc(widget.sellerUid).get();
      if (snapshot.exists) {
        final sellerData = snapshot.data();
        sellerFullName = await sellerData!['fullName'];
      }

      Map<String,String> appointmentDetails = {
      'name': sellerFullName,
      'selleruid': widget.sellerUid,
      'day': widget.selectedDay,
      'hour': widget.selectedHour,
      'field': widget.selectedField,
      'verificationCode': verificationCode,
      'startTime': startTime,
      'endTime': endTime,
      'status': 'pending',
      'paymentStatus' : 'waiting'
    };

    DocumentReference buyerDocRef = await _firestore.collection('Users')
    .doc(currentuser)
    .collection('appointmentbuyer')
    .add({
      'appointmentDetails': appointmentDetails
    });
    return buyerDocRef.id;
    } catch (e){
      print('Error appointment buyer $e');
      return '';
    }
  }

  Future<void> appointmentSeller() async {
  String fullName;
  String verificationCode = generateCode();
  String startTime = widget.selectedHour.split('-')[0];
  String endTime = widget.selectedHour.split('-')[1];

  // Fetch user data once using `get()` to avoid the asynchronous issue
  try {
    final snapshot = await _firestore.collection('Users').doc(currentuser).get();
    if (snapshot.exists) {
      final userdata = snapshot.data();
      fullName = await userdata!['fullName'];
    } else {
      throw Exception("User data not found"); 
    }

    String buyerDocId = await appointmentBuyer(verificationCode, startTime, endTime);

  // Create the appointmentDetails map with the fetched data
  Map<String, String> appointmentDetails = {
    'fullName': fullName,
    'buyerUid': currentuser,
    'buyerDocId' : buyerDocId,
    'day': widget.selectedDay,
    'hour': widget.selectedHour,
    'field':widget.selectedField,
    'verificationCode': verificationCode,
    'verificationState': 'notVerified',
    'startTime':startTime,
    'endTime': endTime,
    'isPastDay': 'false',
    'status': 'pending',
  };
  
    // Add appointment details to Firestore to the seller account
    DocumentReference sellerDocRef = await _firestore
      .collection('Users')
      .doc(widget.sellerUid)
      .collection('appointmentseller')
      .add({
        'appointmentDetails': appointmentDetails,
      });
  
    await _firestore
    .collection('Users')
    .doc(currentuser)
    .collection('appointmentbuyer')
    .doc(buyerDocId)
    .update({'appointmentDetails.sellerDocId' : sellerDocRef.id});
  } catch (e) {
    print('Error seller appointment $e');
  }
  } 

  Future<void> sendRequest() async{
    try {
      await appointmentSeller();
      NotificationModel notificationModel = NotificationModel(widget.selectedHour, widget.selectedDay, widget.selectedField);
      await PushHelper.sendPushBefore(userId: widget.sellerUid, text: notificationModel.notification(), page: 'appointment');
      if (mounted) {
        Showalert(context: context, text: 'Randevu talebi gönderilmiştir').showSuccessAlert();
      }
    } catch (e) {
      print('Error sending notification $e');
      if (mounted){
        Showalert(context: context, text: 'Ooops...').showErrorAlert();
      }
    }
  }
  String generateCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  return List.generate(5, (index) => chars[Random().nextInt(chars.length)]).join();
}
}
