import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowCardDetails extends StatefulWidget {
  const ShowCardDetails({Key? key});

  @override
  State<ShowCardDetails> createState() => _ShowCardDetailsState();
}

class _ShowCardDetailsState extends State<ShowCardDetails> {
  final String? currentUser = FirebaseAuth.instance.currentUser?.uid;

  String? cardHolderName;
  String? cardNumber;
  String? cvvCode;
  String? expiryDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _getCardDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return _buildCardDetails();
            }
          },
        ),
      ),
    );
  }

  Widget _buildCardDetails() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/images/credit_card_background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              width: double.infinity,
              height: 230,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 70),
                    Text(
                      "$cardNumber",
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$cardHolderName",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Row(
                        children: [
                          Text(
                            "$expiryDate",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 100),
                          Text(
                            "$cvvCode",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: 30,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Image.asset("lib/icons/chip.png"),
              ),
            ),
            Positioned(
              bottom: 27,
              left: 30,
              child: SizedBox(
                height: 20,
                child: Text(
                  "Valid",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 27,
              right: 150,
              child: SizedBox(
                child: Text(
                  "Cvv",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCardDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection("Users").doc(currentUser).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.isNotEmpty && data.containsKey("cardDetails")) {
          Map<String, dynamic> cardDetails = data['cardDetails'];
          if (cardDetails.isNotEmpty) {
            cardNumber = cardDetails['cardNumber'];
            expiryDate = cardDetails['expiryDate'];
            cvvCode = cardDetails['cvvCode'];
            cardHolderName = cardDetails['cardHolderName'];
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("error $e");
    }
  }
}
