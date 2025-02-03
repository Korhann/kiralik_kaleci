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
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;

    var collectionBuyer = firestore.collection('Users').doc(currentuser).collection('appointmentbuyer');
    var collectionSeller = firestore.collection('Users').doc(currentuser).collection('appointmentseller');
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
  List<String>? docs;

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
                      final field = appointmentDetails['field'] ?? '';
                      final status = appointmentDetails['status'] ?? 'pending';
                      final docId = docs?[index] ?? '';

                      // Card background color based on status
                      Color cardColor = Colors.white;
                      if (status == 'approved') {
                        cardColor = Colors.green.shade200;
                      } else if (status == 'rejected') {
                        cardColor = Colors.red.shade200;
                      }

                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: cardColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.all(10),
                                  title: Text(
                                    '$name $surname',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_month),
                                          const SizedBox(width: 5),
                                          Text('$day'),
                                          const Spacer(),
                                          const Icon(Icons.watch_later_outlined),
                                          const SizedBox(width: 5),
                                          Text('$hour'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on),
                                          const SizedBox(width: 5),
                                          Text('$field')
                                        ],
                                      )
                                    ],
                                  )
                                ),
                                // Show buttons only if status is pending
                                if (userorseller && status == 'pending') 
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            await approveAppointment(docId, index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: const Text('Onayla'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await rejectAppointment(docId, index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Reddet'),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
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
      
      // Get document IDs for updating a specific user's appointment
      setState(() {
        docs = snapshot.docs.map((doc) => doc.id).toList();
      });
    }
    
    setState(() {
      appointments = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  // Approve Appointment - Updates status to 'approved'
  Future<void> approveAppointment(String docId, int index) async {
    try {
      await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('appointmentseller')
          .doc(docId)
          .update({
            'appointmentDetails.status': 'approved'
          });

      
      setState(() {
        appointments[index]['appointmentDetails']['status'] = 'approved';
      });

    } catch (e) {
      print('Error approving appointment: $e');
    }
  }

  // Reject Appointment - Updates status to 'rejected'
  Future<void> rejectAppointment(String docId, int index) async {
    try {
      await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('appointmentseller')
          .doc(docId)
          .update({
            'appointmentDetails.status': 'rejected'
          });

      setState(() {
        appointments[index]['appointmentDetails']['status'] = 'rejected';
      });

    } catch (e) {
      print('Error rejecting appointment: $e');
    }
  }
}
