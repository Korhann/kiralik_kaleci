import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/CardDetailsPage.dart';
import 'package:kiralik_kaleci/accountmenu.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:kiralik_kaleci/showCardDetails.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // veri tabanından çektiğim veriler
  String? fullName;
  String? email;

  // authentication of the user
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String? currentuser = FirebaseAuth.instance.currentUser?.uid;

  String? cardNumber;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  FutureBuilder<void>(
                  future: _getUserName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "$fullName",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountMenu(),
                        ),
                      );
                    }, 
                    icon: const Icon(
                      Icons.settings,
                      size: 28,
                      color: Colors.black,
                    ),
                  )
                ]
              ),
              const SizedBox(height: 30),
              Container(
                color: Colors.white,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Kaleci Ol",
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      ToggleSwitch(
                        minWidth: 80.0,
                        cornerRadius: 20.0,
                        activeBgColors: [
                          [Colors.green[800]!],
                          [Colors.red[800]!]
                        ],
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey,
                        inactiveFgColor: Colors.white,
                        initialLabelIndex: 0,
                        totalSwitches: 2,
                        labels: const ['Kullanıcı', 'Satıcı'],
                        radiusStyle: true,
                        onToggle: (index) {
                          // case 0 aynı sayfada kalacak case 1 satıcı sayfasına geçecek
                          switch (index) {
                            // aynı sayfada kal
                            case 0:
                              return;
                            // satıcı sayfasına geç
                            case 1:
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SellerMainPage()));
                              break;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  "Hesap",
                  textAlign: TextAlign.start,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 70,
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ad Soyad",
                        style: GoogleFonts.inter(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      FutureBuilder<void>(
                        future: _getUserName(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return Text(
                              "$fullName",
                              style: GoogleFonts.inter(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                              ),
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              /*
              Container(
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Soyad",
                        style: GoogleFonts.inter(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        // this is going to be the lastname of the user
                        "Demir",
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w300),
                      )
                    ],
                  ),
                ),
              ),
              */
              Container(
                height: 1,
                color: Colors.black,
              ),
              Container(
                height: 70,
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email",
                        style: GoogleFonts.inter(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      FutureBuilder(
                          future: _getEmail(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Text(
                                "$email",
                                style: GoogleFonts.inter(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  "Ödeme",
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ShowCardDetails())
                  );
                },
                child: Container(
                  height: 70,
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kart Bilgilerim",
                          style: GoogleFonts.inter(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                        FutureBuilder<void>(
                          future: _getCardNumber(),
                          builder: (context,snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return Text(
                                "$cardNumber",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400
                                ),
                              );
                            }
                            else {
                              return Text("");
                            }
                          }
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 1,
                color: Colors.black,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CardDetails()));
                },
                child: Container(
                  height: 70,
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Kart Ekle",
                          style: GoogleFonts.inter(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                        const Icon(Icons.add, size: 24, color: Colors.black)
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  print("daha sonra yapılacak");
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Favorilerim",
                          style: GoogleFonts.inter(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                        const Icon(Icons.favorite_border, size: 24)
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () {
                        // sign out the user
                        _auth.signOut();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Çıkış Yap",
                            style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          const Icon(Icons.door_back_door,
                              size: 24, color: Colors.black)
                        ],
                      )),
                ),
              ),
              const SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getUserName() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection("Users")
          .doc(currentuser)
          .get();

      if (snapshot.exists) {
        fullName = snapshot.data()?['fullName']?.toString();
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _getEmail() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection("Users")
          .doc(currentuser)
          .get();

      if (snapshot.exists) {
        email = snapshot.data()?['email']?.toString();
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  Future<void> _getCardNumber() async{
    try {
      DocumentSnapshot<Map<String,dynamic>> snapshot = await FirebaseFirestore
      .instance
      .collection("Users")
      .doc(currentuser)
      .get();

      if (snapshot.exists) {
      Map<String,dynamic> data = snapshot.data() as Map<String,dynamic>;
      if (data.isNotEmpty && data.containsKey("cardDetails")) {
        Map<String,dynamic> cardDetails = data['cardDetails'];
        if (cardDetails.isNotEmpty) {
          cardNumber = cardDetails['cardNumber'];
        }
      }
    }
    }catch (e) {
      print("error $e");
    }
  }
}
