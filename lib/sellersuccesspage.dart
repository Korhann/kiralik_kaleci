import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/sellerDetails.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class SellerSuccessPage extends StatefulWidget {
  const SellerSuccessPage({super.key});

  @override
  State<SellerSuccessPage> createState() => _SellerSuccessPageState();
}

class _SellerSuccessPageState extends State<SellerSuccessPage> {

  List<Map<String,dynamic>> userDetails = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUserDetails();
    userorseller = false;
  }

  Future<void> _fetchUserDetails() async{

    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid != null && currentUserUid.isNotEmpty) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUserUid)
      .get();
      if (documentSnapshot.exists) {
        Map<String,dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
        if (data.isNotEmpty && data.containsKey('sellerDetails')) {
          Map<String, dynamic> sellerDetails = data['sellerDetails'];
          Duration duration = const Duration(seconds: 3);
          Timer(duration, () { 
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SellerDetailsPage(sellerDetails: sellerDetails, sellerUid: currentUserUid)));
          });
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sellerbackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Yükleme Tamamlanmıştır',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}