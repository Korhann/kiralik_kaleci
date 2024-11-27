import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/appointmentspage.dart';
import 'package:kiralik_kaleci/earnings.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/settingsMenu.dart';
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


  @override
  void initState() {
    super.initState();
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
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: _userName(),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsMenu(),
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
                              // settings in rengini değiştirmek için(beyaz yapıyor)
                              userorseller = false;
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
                      _getUserName()
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
                      _getEmail()
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
                          _getIbanNo()
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
                Container(
                  height: 1,
                  color: Colors.white,
                ),

                // Kazançlarım sayfası(fiverr daki gibi)
                Stack(
                  children: [
                    Container(
                    height: 70,
                    width: double.infinity,
                    color: sellergrey,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kazançlarım',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
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
                          MaterialPageRoute(builder: (context) => const EarningsPage())
                        );
                      },
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  )
                  ],
                ),
              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Diğer',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 10),

              GestureDetector(
                //TODO user or seller a göre de yapabilirsin belki yada yeni bir sellerappointment page de yapabilirsin
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppointmentsPage())
                  );
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  color: sellergrey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Randevularım',
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.white
                          ),
                        ),
                        const Icon(Icons.alarm, size: 24, color: Colors.white,)
                      ],
                    ),
                  ),
                ),
              ),
              // İlanlarım sayfası
              const SizedBox(height: 60),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () async{
                        // sign out the user
                        _auth.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const MainPage()),
                          (Route<dynamic> route) => false,
                        );
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


  Widget _getUserName() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(currentuser).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Veri bulunamadı');
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text(
          userData['fullName'] ?? '',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight:FontWeight.w400,
            color: Colors.white
          )
        );
      },
    );
  }

  Widget _getEmail() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(currentuser).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Veri bulunamadı');
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text(
          userData['email'] ?? '',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white
          ),
        );
      },
    );
  }

  Widget _getIbanNo() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(currentuser).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Veri bulunamadı');
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        if (userData.containsKey('ibanDetails') && userData['ibanDetails'].isNotEmpty) {
          var ibanDetails = userData['ibanDetails'] as Map<String, dynamic>;
          return Text(
            ibanDetails['ibanNo'] ?? '',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white
            ),
          );
        } else {
          return Text(
            'İban bilgisi yok',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white
            ),
          );
        }
      },
    );
  }
  Widget _userName() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(currentuser).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Veri bulunamadı');
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text(
          userData['fullName'] ?? '',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight:FontWeight.bold,
            color: Colors.white
          )
        );
      },
    );
  }
}
