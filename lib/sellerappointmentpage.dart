import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellerAppointmentPage extends StatefulWidget {
  const SellerAppointmentPage({super.key});

  @override
  State<SellerAppointmentPage> createState() => _SellerAppointmentPageState();
}

class _SellerAppointmentPageState extends State<SellerAppointmentPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;
  
  List<Map<String,dynamic>> appointments = [];
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}