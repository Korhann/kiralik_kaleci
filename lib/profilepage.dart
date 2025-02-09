import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/appointmentspage.dart';
import 'package:kiralik_kaleci/approvedfields.dart';
import 'package:kiralik_kaleci/favouritespage.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/policiespage.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:kiralik_kaleci/settingsMenu.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // veri tabanından çektiğim veriler
  String? fullName;
  String? email;
  // appointmentpage ya göndermek için
  late String sellerUid;
  late String buyerUid;

  // authentication of the user
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
  String? cardNumber;

  @override
  void initState() {
    super.initState();
    getSellerUid();
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
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: _userName() // fontsize 20 olcak
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
                        style: GoogleFonts.roboto(
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
                              // settings in rengini değiştirmek için(siyah yapıyor)
                              userorseller = true;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SellerMainPage()));
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
                  style: GoogleFonts.roboto(
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
                        style: GoogleFonts.roboto(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      _getUserName()
                    ],
                  ),
                ),
              ),
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
                        style: GoogleFonts.roboto(
                            fontSize: 22, fontWeight: FontWeight.w500),
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
                  "Diğer",
                  style: GoogleFonts.roboto(
                      fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async{
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppointmentsPage())
                  );
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
                          'Randevularım',
                          style: GoogleFonts.roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        const Icon(Icons.alarm, size: 24)
                      ],
                    ),
                  ),
                ),
              ),
              Container(height: 1,color: Colors.black),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavouritesPage())
                    
                  );
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
                          style: GoogleFonts.roboto(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                        const Icon(Icons.favorite_border, size: 24)
                      ],
                    ),
                  ),
                ),  
              ),
              Container(height: 1,color: Colors.black),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ApprovedFields())
                  );
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
                            "Onaylı Halı Sahalar",
                            style: GoogleFonts.roboto(
                              fontSize: 22, fontWeight: FontWeight.w500),
                          ),
                          const Icon(Icons.location_on, size: 24)
                        ],
                      ),
                    ),
                  ),
              ),
              Container(height: 1,color: Colors.black),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PoliciesPage())
                  );
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
                          "Kiralık Kaleci",
                          style: GoogleFonts.roboto(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                        const Icon(Icons.handshake_outlined, size: 24)
                      ],
                    ),
                  ),
                ),  
              ),
              const SizedBox(height: 60),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                      onPressed: () async{
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
                            style: GoogleFonts.roboto(
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
            color: Colors.black
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
            color: Colors.black
          ),
        );
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
            color: Colors.black
          )
        );
      },
    );
  }
  // appointmentpage ya göndermek için aldım ama 2 tane var nasıl yapacağına karar ver
  Future<void> getSellerUid() async {

  CollectionReference collectionReference = _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('appointmentbuyer');
  QuerySnapshot querySnapshot = await collectionReference.get();
  
  for (var doc in querySnapshot.docs) {
    final data = doc.data() as Map<String, dynamic>; 
    
    String? sellerUid = data['appointmentDetails']?['selleruid'];
  }
}

}
