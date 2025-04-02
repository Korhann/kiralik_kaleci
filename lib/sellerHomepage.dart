import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/appointmentspage.dart';
import 'package:kiralik_kaleci/selleraddpage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  String currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sellerbackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: sellerbackground,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 10),
          child: Text(
            'Satıcı Ana Sayfa',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                SellerQuickMenus(text: 'İlan Ekle/Düzenle', ontap: () => _navigateToPage('sellerAdd'), icon: Icons.add),
                const SizedBox(height: 10),
                NoOfAppointments(onTap: () => _navigateToPage('appointments')),
                const SizedBox(height: 10),
                SellerQuickMenus(text: 'Kazançlarım Fiverr a bak', ontap: () => _navigateToPage('earnings'), icon: Icons.attach_money)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(String menuOption) async {
    Widget page;
    switch (menuOption) {
      case 'sellerAdd':
        page = const SellerAddPage();
        break;
      case 'appointments':
        page = const AppointmentsPage(whereFrom: 'fromSellerHomePage',);
        break;
      default:
        return; 
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class SellerQuickMenus extends StatelessWidget {

  final String text;
  final VoidCallback ontap;
  final IconData icon;

  const SellerQuickMenus({required this.text, required this.ontap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 50,
          width: MediaQuery.sizeOf(context).width,
          color: sellergrey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  text,
                  style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white
                    ),
                ),
                const Spacer(),
                Icon(
                  icon,
                  size: 24,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoOfAppointments extends StatelessWidget {
  final VoidCallback onTap;

  const NoOfAppointments({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 50,
          width: MediaQuery.sizeOf(context).width,
          color: sellergrey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  "Randevularım",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications,
                      size: 24,
                      color: Colors.white,
                    ),
                    StreamBuilder<int>(
                      stream: getUnreadCount(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == 0) return SizedBox();
                        return Positioned(
                          right: -5,
                          top: -5,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              snapshot.data.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stream<int> getUnreadCount() {
    final String currentUser = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser)
        .collection('appointmentseller')
        .where('appointmentDetails.status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}


