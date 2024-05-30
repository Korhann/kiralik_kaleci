import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/sellerAccountMenu.dart';
import 'package:kiralik_kaleci/selleribanpage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {

  // kullanıcı bilgierli
  String? fullName;
  String? email;
  String? iban;

  int toggleIndex = 1; // Ensure the toggle switch is at the second index

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String? currentuser = FirebaseAuth.instance.currentUser?.uid;

  bool isLoadingName = true;
  bool isLoadingEmail = true;
  bool isLoadingIban = true;

  @override
  void initState() {
    super.initState();
    _getUserName();
    _getEmail();
    _getIbanNo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sellerbackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              isLoadingName
                  ? const CircularProgressIndicator()
                  : Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            fullName ?? 'No name',
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SellerAccountMenu(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings,
                              size: 28, color: Colors.white),
                        ),
                      ],
                    ),
              const SizedBox(height: 30),
              Container(
                color: sellergrey,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Kaleci Ol",
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
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
                        initialLabelIndex: toggleIndex,
                        totalSwitches: 2,
                        labels: const ['Kullanıcı', 'Satıcı'],
                        radiusStyle: true,
                        onToggle: (index) {
                          if (mounted) {
                            setState(() {
                              toggleIndex = index!;
                            });
                          }
                          // case 0 aynı sayfada kalacak case 1 satıcı sayfasına geçecek
                          switch (index) {
                            // aynı sayfada kal
                            case 0:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MainPage()),
                              );
                              break;
                            // satıcı sayfasına geç
                            case 1:
                              return;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // kullanıcı hesap bilgileri
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  "Hesap",
                  textAlign: TextAlign.start,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 70,
                width: double.infinity,
                color: sellergrey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ad Soyad",
                        style: GoogleFonts.inter(
                            fontSize: 22, fontWeight: FontWeight.w500,color: Colors.white
                            ),
                      ),
                      Text(
                        fullName ?? 'No name',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                height: 1,
                color: sellerwhite,
              ),
              Container(
                height: 70,
                width: double.infinity,
                color: sellergrey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email",
                        style: GoogleFonts.inter(
                            fontSize: 22, fontWeight: FontWeight.w500,color: Colors.white
                        ),
                      ),
                      Text(
                        email ?? 'No email',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Ödeme',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Stack(
                  children: [
                    Container(
                    height: 70,
                    width: double.infinity,
                    color: sellergrey,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Iban No',
                            style: GoogleFonts.roboto(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.white
                            ),
                          ),
                          Text(
                            iban ?? 'No iban',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    top: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SellerIbanPage())
                        );
                      },
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  )
                  ],
                ),

              // Kazançlarım sayfası(fiverr daki gibi)

              // İlanlarım sayfası
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
                          backgroundColor: sellergrey),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Çıkış Yap",
                            style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const Icon(Icons.door_back_door,
                              size: 24, color: Colors.white)
                        ],
                      )),
                ),
              ),
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
        setState(() {
          fullName = snapshot.data()?['fullName']?.toString();
          isLoadingName = false;
        });
      } else {
        setState(() {
          isLoadingName = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoadingName = false;
      });
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
        setState(() {
          isLoadingEmail = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoadingEmail = false;
      });
    }
  }
  Future<void> _getIbanNo() async {
    try{
      DocumentSnapshot<Map<String,dynamic>> snapshot = await FirebaseFirestore
      .instance
      .collection('Users')
      .doc(currentuser)
      .get();

      if (snapshot.exists) {
        Map<String,dynamic> data = snapshot.data() as Map<String,dynamic>;
        if (data.isNotEmpty && data.containsKey('ibanDetails')) {
          Map<String,dynamic> ibanDetails = data['ibanDetails'];
          if (ibanDetails.isNotEmpty) {
            iban = ibanDetails['ibanNo'];
            setState(() {
              isLoadingIban = false;
            });
          }
        } 
      }
    } catch(e) {
      print('Error $e');
      setState(() {
        isLoadingIban = false;
      });
    } 
  }
}
