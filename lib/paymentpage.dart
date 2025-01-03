
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/styles/button.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class PaymentPage extends StatefulWidget {
  final String sellerUid;
  final String selectedDay;
  final String selectedHour;

  const PaymentPage({
    super.key,
    required this.sellerUid,
    required this.selectedDay,
    required this.selectedHour
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  //todo: Ödemeden sonra eğer ödeme başarılı ise randevularım a eklenecek.
  /*
  kullanıcı adı soyadı, seçili saat, seçili gün 
  */

  // referanslar
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;
  late String sellerFullName;

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
              height: 200,
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
                    const SizedBox(height: 30),
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
                onPressed: () async{
                  bool paymentSuccessful = await _processPayment();
                  if (paymentSuccessful) {
                    await _markHourAsTaken(widget.selectedDay, widget.selectedHour);
                    appointmentBuyer();
                    appointmentSeller();
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ödeme Başarısız, lütfen tekrar deneyiniz'))
                    );
                  }
              }, 
              style: buttonPrimary,
              child: Text(
                'Ödeme',
                style: GoogleFonts.inter(
                  fontSize: 30,
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
    );
  }
  // ÖDEME BURAYA EKLENECEK
  Future<bool> _processPayment() async {

    // Simulate payment process (replace this with actual payment gateway logic)
    await Future.delayed(const Duration(seconds: 2));
    return true; // Return true if payment is successful
  }

  Future<void> _markHourAsTaken(String day, String hourTitle) async {
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
            print('hours: $hours');

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
  void appointmentBuyer() async{
    Map<String,String> appointmentDetails = {
      'name': sellerFullName,
      'selleruid': widget.sellerUid,
      'day': widget.selectedDay,
      'hour': widget.selectedHour,
    };

    await _firestore.collection('Users')
    .doc(currentuser)
    .collection('appointmentbuyer')
    .add({
      'appointmentDetails': appointmentDetails
    });
  }
  void appointmentSeller() async {
  String fullName;
  
  // Fetch user data once using `get()` to avoid the asynchronous issue
  final snapshot = await _firestore.collection('Users').doc(currentuser).get();
  if (snapshot.exists) {
    final userdata = snapshot.data();
    fullName = userdata!['fullName'] ?? '';
  } else {
    throw Exception("User data not found"); 
  }

  // Create the appointmentDetails map with the fetched data
  Map<String, String> appointmentDetails = {
    'fullName': fullName,
    'buyerUid': currentuser,
    'day': widget.selectedDay,
    'hour': widget.selectedHour,
  };
  
  // Add appointment details to Firestore
  await _firestore
      .collection('Users')
      .doc(widget.sellerUid)
      .collection('appointmentseller')
      .add({
    'appointmentDetails': appointmentDetails,
  });
}

}