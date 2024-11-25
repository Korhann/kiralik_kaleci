import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'globals.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();

  // randevular da haftalık olaraka silinecek
  Future<void> deleteAppointments() async{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;

    var collectionBuyer = _firestore.collection('Users').doc(currentuser).collection('appointmentbuyer');
    var collectionSeller = _firestore.collection('Users').doc(currentuser).collection('appointmentseller');
    var appointmentsBuyer = await collectionBuyer.get();
    var appointmentsSeller = await collectionSeller.get();
    for (var doc in appointmentsBuyer.docs) {
      await doc.reference.delete();
    }
    for (var doc in appointmentsSeller.docs) {
      await doc.reference.delete();
    }
  }
}
class _AppointmentsPageState extends State<AppointmentsPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;

  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground : background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white : Colors.black),
        ),
      ),
      backgroundColor: userorseller ? sellerbackground : background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Randevularım',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: userorseller ? Colors.white : Colors.black,
                ),
              ),
            ),
            // Randevu yoksa bu mesajı göster
            appointments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Randevunuz bulunmamaktadır',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            color: userorseller ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      final appointmentDetails = appointment['appointmentDetails'];
                      final name = appointmentDetails['fullName'] ?? appointmentDetails['name'];
                      final surname = appointmentDetails['surname'] ?? '';
                      final day = appointmentDetails['day'] ?? '';
                      final hour = appointmentDetails['hour'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: Colors.white,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              title: Text(
                                '$name $surname',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  const Icon(Icons.calendar_month),
                                  const SizedBox(width: 5),
                                  Text('$day'),
                                  const Spacer(),
                                  const Icon(Icons.watch_later_outlined),
                                  const SizedBox(width: 5),
                                  Text('$hour')
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchAppointments() async {
    QuerySnapshot snapshot;

    if (userorseller == false) {
      snapshot = await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('appointmentbuyer')
          .get();
    } else {
      snapshot = await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('appointmentseller')
          .get();
    }
    setState(() {
      appointments = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

}
