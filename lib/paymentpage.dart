import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/creditcarduipage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class PaymentPage extends StatefulWidget {
  final String sellerUid;

  const PaymentPage({
    super.key,
    required this.sellerUid
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {

  // referanslar
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;

  Color _buttonColor = Colors.white;

  // kredi kartı için
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController _cvvController = TextEditingController();

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
              height: 80,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          'Kayıtlı Kartlar',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          child: RawMaterialButton(
                            onPressed: () {
                              setState(() {
                                _buttonColor = _buttonColor == Colors.blue ? Colors.white : Colors.blue;

                                if (_buttonColor == Colors.white) {
                                  _cardNumberController.clear();
                                  _expiryDateController.clear();
                                  _cvvController.clear();
                                }
                                if (_buttonColor == Colors.blue) {
                                  _cardDetails();
                                }
                              });
                            },
                            elevation: 2.0,
                            fillColor: _buttonColor,
                            constraints: const BoxConstraints.tightFor(
                              width: 20,
                              height: 20
                            ),
                            shape: const CircleBorder(
                              side: BorderSide(color: Colors.grey)
                            ),
                          ),
                        ),
                        _getCardDetails()
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Başka Kartla Öde',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CardWidget(cardNumberController: _cardNumberController, expiryDateController: _expiryDateController, cvvController: _cvvController)
                  ],
                ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      'Ödenecek Tutar',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Text(
                          'Hizmet Bedeli:',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade700
                            ),
                        ),
                        const Spacer(),
                        _price()
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Future<void> _cardDetails() async{
    DocumentSnapshot snapshot = await _firestore.collection('Users').doc(currentuser).get();

    try {
      if (snapshot.exists) {
        Map<String,dynamic> data = snapshot.data() as Map<String,dynamic>;
          if (data.isNotEmpty && data.containsKey('cardDetails')) {
            var cardDetails = data['cardDetails'];
            _cardNumberController.text = cardDetails['cardNumber'];
            _expiryDateController.text = cardDetails['expiryDate'];
            _cvvController.text = cardDetails['cvvCode'];
          }
        }
      } catch (e) {
        print('Kart bilgileri alınamadı $e');
      }
  }
  Widget _getCardDetails() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('Users').doc(currentuser).snapshots(),
       builder: (context,snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Veri bulunamadı');
        }
        var userData = snapshot.data!.data() as Map<String,dynamic>;
        var cardDetails = userData['cardDetails'];
        return Text(
          cardDetails['cardNumber'] ?? '',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: Colors.black
          ),
        );
       }
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            sellerPrice != null ? '${sellerPrice.toString()}TL' : '',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Colors.black
            ),
          ),
        );
      }
    );
  }
}