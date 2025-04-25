import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/enterVerificationCode.dart';
import 'package:kiralik_kaleci/notification/push_helper.dart';
import 'package:kiralik_kaleci/paymentpage.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'globals.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({
    super.key,
    required this.whereFrom
  });

  final String whereFrom;

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();

  // randevular da haftalık olaraka silinecek
  Future<void> deleteAppointments() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String currentuser = FirebaseAuth.instance.currentUser!.uid;

    var collectionBuyer = firestore
        .collection('Users')
        .doc(currentuser)
        .collection('appointmentbuyer');
    var collectionSeller = firestore
        .collection('Users')
        .doc(currentuser)
        .collection('appointmentseller');
    var appointmentsBuyer = await collectionBuyer.get();
    var appointmentsSeller = await collectionSeller.get();
    for (var doc in appointmentsBuyer.docs) {
      await doc.reference.delete();
    }
    for (var doc in appointmentsSeller.docs) {
      await doc.reference.delete();
    }
  }
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;

  List<Map<String, dynamic>> appointments = [];
  List<String>? docs;
  Color paymentColor = Colors.green;

  late Future<void> fetchAppts;

  @override
  void initState() {
    super.initState();
   fetchAppts =  _fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWithBackButton(
      child: FutureBuilder(
        future: fetchAppts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.only(top: 40),
              child: AppointmentsShimmer()
            );
          }
          return Scaffold(
          appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground : background,
        leading: IconButton(
          onPressed: () {
            // geri ye basınca yanlış yerden çıkış yaptığı için kullandım
            if (userorseller) {
              if (widget.whereFrom == 'fromProfile') {
                Navigator.of(context).pop();
              } else if (widget.whereFrom == 'fromNoti') {
                Navigator.pushAndRemoveUntil<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const SellerMainPage(index: 2)),
                ModalRoute.withName('/'),
                );
              } else if (widget.whereFrom == 'fromSellerHomePage') {
                Navigator.pushAndRemoveUntil<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const SellerMainPage(index: 0)),
                ModalRoute.withName('/'),
                );
              }
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: Icon(Icons.arrow_back,color: userorseller ? Colors.white : Colors.black),
        ),
      ),
      backgroundColor: userorseller ? sellerbackground : background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Randevularım',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: userorseller ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (userorseller == false)
              buyerStatusInfo()
            else
              sellerStatusInfo(),
            appointments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Randevunuz bulunmamaktadır',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            color: userorseller ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      final appointmentDetails = appointment['appointmentDetails'];
                      final name = appointmentDetails['fullName'] ?? appointmentDetails['name'];
                      final surname = appointmentDetails['surname'] ?? '';
                      final day = appointmentDetails['day'] ?? '';
                      final hour = appointmentDetails['hour'] ?? '';
                      final field = appointmentDetails['field'] ?? '';
                      final status = appointmentDetails['status'] ?? 'pending';
                      final paymentStatus = appointmentDetails['paymentStatus'] ?? 'waiting';
                      final verificationCode = appointmentDetails['verificationCode'] ?? '';
                      final verificationState = appointmentDetails['verificationState'] ?? '';
                      final isPastDay = appointmentDetails['isPastDay'] ?? '';
                      final docId = docs?[index] ?? '';

                      // TODO: Alıcıda isPastDay verisi olmadığı için renkleri almıyor 
                      Color cardColor = Colors.white;
                      if (status == 'approved' && paymentStatus == 'done') {
                        cardColor = Colors.green.shade500;
                      } else if (status == 'approved' && paymentStatus == 'waiting') {
                        cardColor = Colors.green.shade200;
                      } else if (status == 'rejected') {
                        cardColor = Colors.red.shade200;
                      } else if (status == 'pending' && paymentStatus == 'waiting' && isPastDay == 'false') {
                        cardColor = Colors.orange.shade200;
                      } else if (status == 'approved' || (paymentStatus == 'taken' || isPastDay == 'true')) {
                        cardColor = Colors.grey;
                      } 
                      

                      return AppointmentView(
                        cardColor: cardColor,
                        name: name,
                        surname: surname,
                        day: day,
                        hour: hour,
                        field: field,
                        status: status,
                        paymentStatus: paymentStatus,
                        sellerUid: appointmentDetails!['selleruid'] ?? '',
                        appointmentDetails: appointmentDetails,
                        verificationCode : verificationCode,
                        verificationState: verificationState,
                        isPastDay: isPastDay,
                        docId: docId,
                        userorseller: userorseller,
                        onApprove: () async {
                          await approveAppointment(docId, index);
                        },
                        onReject: () async {
                          await rejectAppointment(docId, index);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20)
          ],
        ),
      ),
    );
        } 
      ),
    );
  }

  Future<void> _fetchAppointments() async {
    QuerySnapshot snapshot;

    snapshot = await _firestore.collection('Users')
    .doc(currentuser)
    .collection(userorseller ? 'appointmentseller' : 'appointmentbuyer')
    .get();

    List<String> tempDocs = snapshot.docs.map((doc) => doc.id).toList();
    List<Map<String, dynamic>> tempAppointments = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    if (userorseller) {
      await checkAllPastDaysSeller(tempAppointments, tempDocs);
    } else {
      await checkAllPastDaysUser(tempAppointments, tempDocs);
    }
    
  // Step 2: Re-fetch to get updated values from Firestore
    snapshot = await _firestore
      .collection('Users')
      .doc(currentuser)
      .collection(userorseller ? 'appointmentseller' : 'appointmentbuyer')
      .get();

  if (mounted) {
    setState(() {
      docs = snapshot.docs.map((doc) => doc.id).toList();
      appointments = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }
}


  Future<void> checkAllPastDaysSeller(List appointments, List<String>? docIds) async {
  for (int i = 0; i < appointments.length; i++) {
    final appointmentDetails = appointments[i]['appointmentDetails'];
    final day = appointmentDetails['day'] ?? '';
    final docId = docIds![i];
    await CheckDaysPastSeller.isPast(day, docId);
  }
}
  
  Future<void> checkAllPastDaysUser(List appointments, List<String>? docIds) async {
    for (int i = 0; i < appointments.length; i++) {
    final appointmentDetails = appointments[i]['appointmentDetails'];
    final day = appointmentDetails['day'] ?? '';
    final docId = docIds![i];
    await CheckDaysPastUser.isPast(day, docId);
  }
  }


  // Updates status to 'approved'
  Future<void> approveAppointment(String docId, int index) async {
    String appointmentDetails = 'appointmentDetails';
    try {
      await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('appointmentseller')
          .doc(docId)
          .update({'appointmentDetails.status': 'approved'});

      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('appointmentseller')
          .doc(docId)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? appointmentData = documentSnapshot.data();
        if (appointmentData != null &&
            appointmentData.containsKey('appointmentDetails')) {
          String buyerUid = appointmentData['appointmentDetails']['buyerUid'];
          String buyerDocId =
              appointmentData['appointmentDetails']['buyerDocId'];

          String hour = appointmentData[appointmentDetails]['hour'];
          String day = appointmentData[appointmentDetails]['day'];
          String field = appointmentData[appointmentDetails]['field'];

          // alıcı için status update (renkleri göstermek için - turuncu,yeşil,kırmzı)
          await _firestore
              .collection('Users')
              .doc(buyerUid)
              .collection('appointmentbuyer')
              .doc(buyerDocId)
              .update({'appointmentDetails.status': 'approved'});

          // alıcı ödeme yapması için bildirim gönder
          await PushHelper.sendPushPayment(
              sellerUid: currentuser,
              buyerUid: buyerUid,
              selectedDay: day,
              selectedHour: hour,
              selectedField: field,
              docId: buyerDocId);
        } else {
          print('appointment details does not exist');
        }
      } else {
        print('document snapshot does not exist');
      }

      setState(() {
        appointments[index]['appointmentDetails']['status'] = 'approved';
      });
    } catch (e) {
      print('Error approving appointment: $e');
    }
  }

  Future<void> rejectAppointment(String docId, int index) async {
    try {
      await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('appointmentseller')
          .doc(docId)
          .update({'appointmentDetails.status': 'rejected', 'appointmentDetails.paymentStatus': 'denied'});
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('appointmentseller')
          .doc(docId)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? appointmentData = documentSnapshot.data();
        if (appointmentData != null &&
            appointmentData.containsKey('appointmentDetails')) {
          String buyerUid = appointmentData['appointmentDetails']['buyerUid'];
          String buyerDocId = appointmentData['appointmentDetails']['buyerDocId'];

          // alıcı için status update (renkleri göstermek için - turuncu,yeşil,kırmzı)
          await _firestore
              .collection('Users')
              .doc(buyerUid)
              .collection('appointmentbuyer')
              .doc(buyerDocId)
              .update({'appointmentDetails.status': 'rejected'});
        } else {
          print('appointment details does not exist');
        }
      } else {
        print('document snapshot does not exist');
      }

      if (mounted) {
        setState(() {
          appointments[index]['appointmentDetails']['status'] = 'rejected';
        });
      }
    } catch (e) {
      print('Error rejecting appointment: $e');
    }
  }

  //
  Widget buyerStatusInfo() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.green.shade500,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Alındı',
              style: TextStyle(color: userorseller ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.red.shade200,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Reddedildi',
              style:
                  TextStyle(color: userorseller ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.orange.shade200,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Beklemede',
              style:
                  TextStyle(color: userorseller ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.green.shade200,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Ödeme gerekiyor',
              style:
                  TextStyle(color: userorseller ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Geçmiş',
              style:
                  TextStyle(color: userorseller ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget sellerStatusInfo() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.green.shade500,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Onaylandı',
              style:
                  TextStyle(color: userorseller ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.red.shade200,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Reddedildi',
              style:
                  TextStyle(color: userorseller ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.orange.shade200,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Beklemede',
              style:
                  TextStyle(color: userorseller ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 10,
                width: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'Geçmiş',
              style:
                  TextStyle(color: userorseller ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class apptsEmpty extends StatelessWidget {
  const apptsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            'Randevunuz bulunmamaktadır',
            style: GoogleFonts.poppins(
              fontSize: 26,
              color: userorseller ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class AppointmentView extends StatelessWidget {
  final Color cardColor;
  final String name;
  final String surname;
  final String day;
  final String hour;
  final String field;
  final String status;
  final String paymentStatus;
  final String sellerUid;
  final Map<String, dynamic> appointmentDetails;
  final String verificationCode;
  final String verificationState;
  final String isPastDay;
  final String docId;
  final bool userorseller;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const AppointmentView({
    Key? key,
    required this.cardColor,
    required this.name,
    required this.surname,
    required this.day,
    required this.hour,
    required this.field,
    required this.status,
    required this.paymentStatus,
    required this.sellerUid,
    required this.appointmentDetails,
    required this.verificationCode,
    required this.verificationState,
    required this.isPastDay,
    required this.docId,
    required this.userorseller,
    this.onApprove,
    this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(10),
                title: nameSurname(name: name, surname: surname),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconDayHour(day: day, hour: hour),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            field,
                          ),
                        ),
                        const Spacer(),
                        buildRightSideWidget(context: context ,userorseller: userorseller, status: status, paymentStatus: paymentStatus, verificationCode: verificationCode, docId: docId, appointmentDetails: appointmentDetails, verificationState: verificationState, isPastDay: isPastDay, hour: hour)
                      ],
                    ),
                  ],
                ),
              ),
              if (userorseller && status == 'pending' && isPastDay == 'false')
                sellerApproveOrReject(onApprove: onApprove, onReject: onReject)
            ],
          ),
        ),
      ),
    );
  }
  Widget buildRightSideWidget({
    required BuildContext context,
    required bool userorseller,
    required String status,
    required String paymentStatus,
    required String verificationCode,
    required String verificationState,
    required String isPastDay,
    required String docId,
    required Map<String, dynamic> appointmentDetails,
    required String hour
  }) {
    // kullanıcı için
  if (!userorseller) {
    //todo: ilk if döngüsü gece maçları için iyi ama sonrası için değil(kullanıcı ertesi gün ödeme yapabilir yanlışlıkla)
    if (status == 'approved' && paymentStatus == 'waiting') {
      return paymentButton(appointmentDetails: appointmentDetails, docId: docId);
    } else if (status == 'approved' && paymentStatus == 'done') {
      return Text(verificationCode);
      // gece olduğu zaman kaleci kodu alabilsin diye gece saatlerini dışarda tutuyorum 
    } else if (isPastDay == 'true' && (hour != '00:00-01:00' || hour != '01:00-02:00')) {
      return showTextBasedOnGreyCard(isPastDay: isPastDay, paymentStatus: paymentStatus);
      //todo: seller da 12-1,1-2 yi geçmiş olarak saymıyor ama kullanıcıda sayıyor.
    } else {
      return showTextBasedOnStatus(status: status);
    }
    // kaleci için
  } else if (userorseller && verificationState == 'notVerified' && status == 'approved' && isPastDay == 'false') {
    return ElevatedButton(
      onPressed: () async{
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EnterVerificationCode(docId: docId))
        );
      }, 
      child: Text('Kodu gir')
    );
  } else if ((hour == '00:00-01:00' || hour == '01:00-02:00') && isPastDay == 'true') {
    return Text('Geçmiş');
  } else {
    return const SizedBox();
  }
}
}

class CheckDaysPastSeller {
  static Future<void> isPast(String day, String docId) async{
    String currentuser = FirebaseAuth.instance.currentUser!.uid;
    List<String> orderedDays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    final int currentDayIndex = now.weekday - 1; // Monday is 1
    final int inputDayIndex = orderedDays.indexOf(day);

    if (inputDayIndex == -1) {
      throw ArgumentError('Invalid day name: $day');
    }
    if (inputDayIndex < currentDayIndex) {
      final docRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentuser)
        .collection('appointmentseller')
        .doc(docId);

      final snapshot = await docRef.get();
      final alreadyPast = snapshot['appointmentDetails']['isPastDay'] ?? false;

      if (alreadyPast == 'false') {
        await docRef.update({
          'appointmentDetails.isPastDay': 'true',
        });
      }
    }
  }
}
// 'waiting' olan günlerin geçdiğini gösteriyor
class CheckDaysPastUser {
  static Future<void> isPast(String day, String docId) async{
    String currentuser = FirebaseAuth.instance.currentUser!.uid;
    List<String> orderedDays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    final now = DateTime.now().toUtc().add(const Duration(hours: 3));
    final int currentDayIndex = now.weekday - 1; // Monday is 1
    final int inputDayIndex = orderedDays.indexOf(day);

    if (inputDayIndex == -1) {
      throw ArgumentError('Invalid day name: $day');
    }
    if (inputDayIndex < currentDayIndex) {
      final docRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentuser)
        .collection('appointmentbuyer')
        .doc(docId);

      final snapshot = await docRef.get();
      final isPastDay = snapshot['appointmentDetails']['isPastDay'] ?? false;

      if (isPastDay == 'false') {
        await docRef.update({
          'appointmentDetails.isPastDay': 'true',
        });
      }
    }
  }
}


class iconDayHour extends StatelessWidget {
  final String day;
  final String hour;
  const iconDayHour({
    Key? key,
    required this.day,
    required this.hour,
    }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_month),
        const SizedBox(width: 5),
        Text(day),
        const Spacer(),
        const Icon(Icons.watch_later_outlined),
        const SizedBox(width: 5),
        Text(hour),
      ],
    );
  }
}
class nameSurname extends StatelessWidget {
  final String name;
  final String surname;
  const nameSurname({
    super.key,
    required this.name,
    required this.surname
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$name $surname',
      style: GoogleFonts.poppins(
        fontSize: 18,
        color: Colors.black,
      ),
    );
  }
}
class paymentButton extends StatelessWidget {
  final Map<String, dynamic> appointmentDetails;
  final String docId;
  const paymentButton({
    Key? key,
    required this.appointmentDetails,
    required this.docId
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentUser = FirebaseAuth.instance.currentUser!.uid;
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>PaymentPage (
              sellerUid:appointmentDetails['selleruid'],
              buyerUid: currentUser,
              selectedDay:appointmentDetails['day'],
              selectedHour:appointmentDetails['hour'],
              selectedField:appointmentDetails['field'],
              docId: docId,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      child: const Text(
        'Ödeme yap',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
class showTextBasedOnStatus extends StatelessWidget {
  final String status;
  const showTextBasedOnStatus({Key? key,required this.status}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      status == 'pending' ? 'Beklemede' : status == 'rejected' ? 'Reddedildi' : '',
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.black,
      ),
    );
  }
}

class showTextBasedOnGreyCard extends StatelessWidget {
  final String isPastDay;
  final String paymentStatus;
  const showTextBasedOnGreyCard({
    super.key,
    required this.isPastDay,
    required this.paymentStatus
  });

  @override
  Widget build(BuildContext context) {
    return Text(
        isPastDay == 'true' && paymentStatus != 'taken' ? 'Geçmiş'
      : isPastDay == 'false' && paymentStatus == 'taken' ? 'Dolu'
      : '',
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.black,
      ),
    );
  }
}
class sellerApproveOrReject extends StatelessWidget {
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  const sellerApproveOrReject({
    Key? key,
    required this.onApprove,
    required this.onReject
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Onayla'),
                      ),
                      ElevatedButton(
                        onPressed: onReject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Reddet'),
                      ),
                    ],
                  ),
                );
  }
}


