import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/appointmentspage.dart';
import 'package:kiralik_kaleci/earnings.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/loginpage.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/sellerDetails.dart';
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

  final String currentuser = FirebaseAuth.instance.currentUser!.uid;
  Map<String,dynamic> sellerDetails = {};
  @override
  void initState() {
    super.initState();
    //getUserDetails();
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
                    child: UserNameHeaderText(),
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
              BeSellerOrUser(),
              
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
              UserName(),

              Container(
                height: 1,
                color: sellerwhite,
              ),

              Email(),
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SellerIbanPage())
                  );
                },
                child: Stack(
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
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                    ],
                  ),
              ),
                Container(
                  height: 1,
                  color: Colors.white,
                ),

                // Kazançlarım sayfası(fiverr daki gibi)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EarningsPage())
                    );
                  },
                  child: OtherBars(
                    text: 'Kazançlarım',
                    icon: Icons.forward,
                    iconColor: Colors.white,
                  )
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppointmentsPage(whereFrom: 'fromProfile'))
                  );
                },
                child: OtherBars(
                  text: 'Randevularım',
                  icon: Icons.alarm,
                  iconColor: Colors.white
                )
              ),
              Container(
                height: 1,
                color: Colors.white,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SellerDetailsPage(sellerDetails: sellerDetails, sellerUid: currentuser))
                  );
                },
                child: OtherBars(
                  text: 'İlanlarım',
                  icon: Icons.diamond,
                  iconColor: Colors.white,
                )
              ),
              // İlanlarım sayfası
              const SizedBox(height: 60),

              SignUserOut(),

              const SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }

  Widget _getIbanNo() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(currentuser).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
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
  Future<void> getUserDetails() async{
    try{
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
      .collection('Users')
      .doc(currentuser)
      .get();

      if (documentSnapshot.exists) {
        Map<String,dynamic> data = documentSnapshot.data() as Map<String,dynamic>;
        if (data.isNotEmpty && data.containsKey('sellerDetails')) {
          sellerDetails = data['sellerDetails'];
        }
      }
    }catch (e) {
      print('$e');
    }
  }
}

class UserName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
              style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            UserNameText(),
          ],
        ),
      ),
    );
  }
}

class UserNameText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(currentuser)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Veri bulunamadı');
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text(userData['fullName'] ?? '',
            style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white));
      },
    );
  }
}

class UserNameHeaderText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentuser)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('Veri bulunamadı');
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return Text(userData['fullName'] ?? '',
              style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white));
        });
  }
}

class OtherBars extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;

  const OtherBars({required this.text, required this.icon,this.iconColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      color: sellergrey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white
            ),
            ),
            Icon(icon,color: iconColor)
          ],
        ),
      ),
    );
  }
}

class Email extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
              style:GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            EmailText()
          ],
        ),
      ),
    );
  }
}

class EmailText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(currentuser)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Veri bulunamadı');
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Text(
          userData['email'] ?? '',
          style: GoogleFonts.roboto(
              fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
        );
      },
    );
  }
}

class BeSellerOrUser extends StatelessWidget {
  const BeSellerOrUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
                color: sellergrey,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Kaleci Ol",
                        style: GoogleFonts.roboto(
                            fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
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
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: const ['Kullanıcı', 'Kaleci'],
                        radiusStyle: true,
                        onToggle: (index) {
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
              );
  }
}
class SignUserOut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    return Center(
      child: SizedBox(
        width: 200,
        height: 60,
        child: ElevatedButton(
            onPressed: () async {
              // sign out the user
              await _auth.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: sellergrey),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Çıkış Yap",
                  style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Icon(Icons.door_back_door, size: 24, color: Colors.white)
              ],
            )),
      ),
    );
  }
}
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: sellergrey);
  }
}