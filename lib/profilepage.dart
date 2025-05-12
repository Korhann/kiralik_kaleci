import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/appointmentspage.dart';
import 'package:kiralik_kaleci/approvedfields.dart';
import 'package:kiralik_kaleci/favouritespage.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/policiespage.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:kiralik_kaleci/settingsMenu.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/userorseller.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  // veri tabanından çektiğim veriler
  String? fullName;
  String? email;
  // appointmentpage ya göndermek için
  late String sellerUid;
  late String buyerUid;

  // authentication of the user
  final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
  String? cardNumber;
  
  @override
  void initState() {
    super.initState();
    saveUserType('user');
    userorseller = false;
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
                  child: UserNameHeaderText()
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
              ]),
              const SizedBox(height: 30),
              BeSellerOrUser(),
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
              // kullanıcı adı
              UserName(),
    
              Container(
                height: 1,
                color: Colors.black,
              ),
    
              // email
              Email(),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  "Diğer",
                  style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
    
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AppointmentsPage(whereFrom: 'fromProfile'))
                );
                },
                child: OtherBars(
                  text: 'Randevularım',
                  icons: Icon(Icons.alarm, size: 24),
                ),
              ),
    
              Container(height: 1, color: Colors.black),
    
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FavouritesPage())
                );
                },
                child: OtherBars(
                  text: 'Favorilerim',
                  icons: Icon(Icons.favorite_border,size: 24,),
                ),
              ),
    
              Container(height: 1, color: Colors.black),
    
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ApprovedFields())
                );
                },
                child: OtherBars(
                  text: 'Onaylı Halı Sahalar',
                  icons: Icon(
                  Icons.location_on,size: 24,),
                ),
              ),
    
              Container(height: 1, color: Colors.black),
    
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PoliciesPage())
                );
                },
                child: OtherBars(
                  text: 'Kiralık Kaleci',
                  icons: Icon(Icons.handshake_outlined,size: 24,),
                ),
              ),
    
              const SizedBox(height: 60),
    
              SignUserOut(),
    
              const SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }

  //todo: FirebaseException ([cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.)
  // Future<void> getSellerUid() async {
  //   CollectionReference collectionReference = _firestore
  //       .collection('Users')
  //       .doc(currentuser)
  //       .collection('appointmentbuyer');
  //   QuerySnapshot querySnapshot = await collectionReference.get();

  //   for (var doc in querySnapshot.docs) {
  //     final data = doc.data() as Map<String, dynamic>;

  //     String? sellerUid = data['appointmentDetails']?['selleruid'];
  //   }
  // }
}

class Email extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
              style:
                  GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
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
              fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
        );
      },
    );
  }
}

class UserName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
              style:
                  GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
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
                color: Colors.black));
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
            return LoadingWidget();
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text('Veri bulunamadı');
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return Text(userData['fullName'] ?? '',
              style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black));
        });
  }
}
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white);
  }
}

class OtherBars extends StatelessWidget {
  final String text;
  final Icon icons;

  const OtherBars({required this.text, required this.icons});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: GoogleFonts.roboto(
                  fontSize: 22, fontWeight: FontWeight.w500),
            ),
            icons
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
              _auth.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
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
                const Icon(Icons.door_back_door, size: 24, color: Colors.black)
              ],
            )),
      ),
    );
  }
}
class BeSellerOrUser extends StatefulWidget {
  @override
  State<BeSellerOrUser> createState() => _BeSellerOrUserState();
}

class _BeSellerOrUserState extends State<BeSellerOrUser> {
  @override
  Widget build(BuildContext context) {
    return Container(
                color: Colors.white,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Kaleci Ol",
                        style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500),
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
                        labels: const ['Kullanıcı', 'Kaleci'],
                        radiusStyle: true,
                        onToggle: (index) async{
                          // case 0 aynı sayfada kalacak case 1 satıcı sayfasına geçecek
                          switch (index) {
                            // aynı sayfada kal
                            case 0:
                              return;
                            // satıcı sayfasına geç
                            case 1:
                              try {
                                if (await InternetConnection().hasInternetAccess) {
                                userorseller = true;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SellerMainPage(index: 2,)
                                  )
                                );
                              break;
                                } else {
                                  Showalert(context: context, text: 'Ooops...').showErrorAlert();
                                  setState(() {
                                    index = 0;
                                  });
                                }
                              } catch (e) {
                                print('Error switching to seller $e');
                              }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
  }
}
