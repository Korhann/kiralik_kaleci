import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/appointmentspage.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/notification/push_helper.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

class PaymentPage extends StatefulWidget {
  final String? sellerUid;
  final String? sellerDocId;
  final String? buyerUid;
  final String? selectedDay;
  final String? selectedHour;
  final String? selectedField;
  final String? buyerDocId;
  const PaymentPage({
    super.key,
    this.sellerUid,
    this.sellerDocId,
    this.buyerUid,
    this.selectedDay,
    this.selectedHour,
    this.selectedField,
    this.buyerDocId
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //todo : uygulamadan çıkış yapılmışken bildirime basınca oluyor(null check used on null value)
  String currentuser = FirebaseAuth.instance.currentUser!.uid;
  late String sellerFullName;
  bool isPaymentLoading = false;

  // this informations are for the payment
  late String buyerName;
  late String buyerLastName;
  late String buyerEmail;
  late int buyerPrice;
  late String buyerIpNo;
  late String buyerPhoneNo;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPaymentInformation();
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
            // birden fazla push olduğu için bunu kullandım
            Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(builder: (BuildContext context) => const MainPage(index: 0)),
            ModalRoute.withName('/'),
            );
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
              child: isPaymentLoading 
              ? CircularProgressIndicator() 
              : ElevatedButton(
                onPressed: () async{
                  await checkIfDayPast();
                  bool? hourTaken = await checkIfHourTaken();
                  bool isPast = await checkIfHourPast();
                  if (hourTaken == false && isPast == false) {
                    bool isSuccess = await _processPayment();
                    await sendNotificationToSeller();
                    if (isSuccess) {
                      await _markHourTaken();
                      Showalert(context: context, text: 'İşlem Başarılı').showSuccessAlert();
                    } else {
                      Showalert(context: context, text: 'Ooopps...').showErrorAlert();
                    }
                  } else {
                    if (hourTaken && isPast == false) {
                      await markAppointmentTaken();
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 5),
                        content: Text('Seçtiğiniz saat başkası tarafından alınmıştır'),
                        backgroundColor: Colors.red,
                      )
                    );
                    } else if (isPast && hourTaken == false) {
                      await markIsPastDay();
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 5),
                        content: Text('Seçtiğiniz saat geçmiştir'),
                        backgroundColor: Colors.red,
                      )
                    );
                    } else {
                      await markAppointmentTaken();
                      await markIsPastDay();
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 5),
                        content: Text('Seçtiğiniz saat başkası tarafından alınmış veya geçmiştir'),
                        backgroundColor: Colors.red,
                      )
                    );
                    }
                  }
                }, 
              style: GlobalStyles.buttonPrimary(context),
              child: Text(
                'Ödeme',
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
  Widget _selectedField() {
    return Text(
      widget.selectedField!,
      style: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    );
  }

  Widget _selectedDay() {
  return Text(
    widget.selectedDay!,
    style: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
  );
}
  Widget _selectedHour() {
  return Text(
    widget.selectedHour!,
    style: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
  );
}

  Widget _price() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('Users').doc(widget.sellerUid).snapshots(),
      builder: (context,snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Veri bulunamadı');
        }
        var userData = snapshot.data!.data() as Map<String,dynamic>;
        if (widget.selectedHour == '00:00-01:00' || widget.selectedHour == '01:00-02:00') {
          var sellerDetails = userData['sellerDetails'];
          var sellerPrice = sellerDetails['sellerPriceMidnight'];


          // appointment page için
          sellerFullName = sellerDetails['sellerFullName'];

          return Text(
            sellerPrice != null ? '${sellerPrice.toString()}TL' : '',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: Colors.black
            ),
          );
        } else {
          var sellerDetails = userData['sellerDetails'];
          var sellerPrice = sellerDetails['sellerPrice'];

          // appointment page için
          sellerFullName = sellerDetails['sellerFullName'];

          return Text(
            sellerPrice != null ? '${sellerPrice.toString()}TL' : '',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: Colors.black
            ),
          );
        }
      }
    );
  }
  //todo: sandbox ta fiyatı 1.20 olarak gösteriyor, normalde de öyle mi diye sor
  Future<bool> _processPayment() async {
    try {
      setState(() {
        isPaymentLoading = true;
      });
      final response = await http.post(Uri.parse('https://europe-west2-kiralikkaleci-21f26.cloudfunctions.net/api/checkout-form'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': buyerName,
        'surname': buyerLastName,
        'email': buyerEmail,
        'phone': buyerPhoneNo,
        'price': buyerPrice.toString(),
        'ip': buyerIpNo,
        'sellerId': widget.sellerUid,
        'buyerId': widget.buyerUid,
        'sellerDocId': widget.sellerDocId 
      }),
    );
      if (response.statusCode == 200) {
      await updatePaymentStatus();
      setState(() {
        isPaymentLoading = false;
      });
      return true;
      } else {
        print('Payment error: ${response.body}');
        setState(() {
          isPaymentLoading = false;
        });
        return false;
      }
    } catch (e) {
      print('Payment not succesfull $e');
    }
    return false;
  }


  Future<void> updatePaymentStatus() async {
    try {
      await _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentbuyer')
      .doc(widget.buyerDocId)
      .update({
        'appointmentDetails.paymentStatus' : 'done'
      });
    } catch (e) {
      print('Error updating payment status $e');
    }
  }

  Future<void> checkIfDayPast() async{
    try {
      DocumentReference<Map<String, dynamic>> documentReference = _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentbuyer')
      .doc(widget.buyerDocId);

      final snapshot = await documentReference.get();
      final day = snapshot['appointmentDetails']['day'] ?? '';
      final startTime = snapshot['appointmentDetails']['startTime'];
      await CheckDaysPastUser.isPast(day, widget.buyerDocId!,startTime);
    } catch (e) {
      print('Error checking hour $e');
    }
  }

  Future<void> _markHourTaken() async {
    DocumentReference docref = _firestore.collection('Users').doc(widget.sellerUid);

    try {
      DocumentSnapshot sellerDoc = await docref.get();
      if (!sellerDoc.exists) {
        return;
      }
      Map<String,dynamic>? sellerData = sellerDoc.data() as Map<String,dynamic>;
      List<dynamic> hourList = List.from(sellerData['sellerDetails']['selectedHoursByDay'][widget.selectedDay]);
      for (var hour in hourList) {
        if (hour['title'] == widget.selectedHour) {
          hour['istaken'] = true;
          hour['takenby'] = currentuser;
          break;
        }
      }
      await docref.update({'sellerDetails.selectedHoursByDay.${widget.selectedDay}':hourList});
    } catch (e) {
      print('Error $e');
    }
  }

  Future<bool> checkIfHourPast() async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference = _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentbuyer')
      .doc(widget.buyerDocId);

      final snapshot = await documentReference.get();
      final isPastDay = snapshot['appointmentDetails']['isPastDay'] ?? false;
      if (isPastDay == 'true') {
        return true;
      } else if (isPastDay == 'false') {
        return false;
      }
    } catch (e) {
      print('Error checking hour $e');
    }
    return false;
  }

  Future<bool> checkIfHourTaken() async {
    try {
      DocumentSnapshot snapshot = await _firestore
        .collection('Users')
        .doc(widget.sellerUid)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.isNotEmpty && data.containsKey('sellerDetails')) {
        Map<String, dynamic> sellerDetails = data['sellerDetails'];
        if (sellerDetails.containsKey('selectedHoursByDay')) {
          Map<String, dynamic> selectedHoursByDay = sellerDetails['selectedHoursByDay'];
          if (selectedHoursByDay.containsKey(widget.selectedDay)) {
            List<dynamic> hoursList = selectedHoursByDay[widget.selectedDay];
            var mathcingHour = hoursList.firstWhere((hour) => hour['title'] == widget.selectedHour);
            if (mathcingHour != null) {
              return mathcingHour['istaken'] ?? false;
            }
          }
        }
      }
    }
    }catch (e) {
      print('Error checking is taken value $e');
    }
    return false;
  }

  Future<void> markAppointmentTaken() async {
    try {
      await _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentbuyer')
      .doc(widget.buyerDocId)
      .update({
        'appointmentDetails.paymentStatus' : 'taken'
      });
    }catch (e) {
      print('Appointment could not mark as taken');
    }
  }
  Future<void> markIsPastDay() async{
    try {
      await _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentbuyer')
      .doc(widget.buyerDocId)
      .update({
        'appointmentDetails.isPastDay' : 'true'
      });
    } catch (e) {
      print('is past day could not be marked $e');
    }
  }
  Future<void> sendNotificationToSeller() async {
    await PushHelper.sendPushBefore(userId: widget.sellerUid!, text: 'Ödeme alınmıştır', page: 'appointment');
  }
  Future<void> getPaymentInformation() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(widget.buyerUid).get();

      if (userDoc.exists) {
        buyerName = userDoc['fullName'];
        buyerLastName = userDoc['fullName'];
        buyerEmail = userDoc['email'];
        await getSellerPrice();
        await getPhoneNo();
        getIpNo();
      }
    } catch (e){
      print('Error getting payment info $e');
    }
  }
  void getIpNo() async{
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    buyerIpNo = wifiIP!;
  }
  Future<void> getSellerPrice() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Users').doc(widget.sellerUid).get();
      var sellerData = snapshot.data() as Map<String,dynamic>;
      if (widget.selectedHour == '00:00-01:00' || widget.selectedHour == '01:00-02:00') {
        buyerPrice = sellerData['sellerDetails']['sellerPriceMidnight'];
      } else {
        buyerPrice = sellerData['sellerDetails']['sellerPrice'];
      }
    } catch (e){
      print('Error getting price $e');
    }
  }
  Future<void> getPhoneNo() async{
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Users').doc(currentuser).get();
      var data = snapshot.data() as Map<String,dynamic>;
      buyerPhoneNo = data['phoneNo'];
      print(buyerPhoneNo);
    } catch (e) {
      print('Error getting phone no $e');
    }
  }
}