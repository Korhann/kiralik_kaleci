import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/approvedfield.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class ApprovedFields extends StatefulWidget {
  const ApprovedFields({super.key});

  @override
  State<ApprovedFields> createState() => _ApprovedFieldsState();
}

class _ApprovedFieldsState extends State<ApprovedFields> {

  List<String> approvedFields = [];

  @override
  void initState() { 
    super.initState();
    ApprovedField.approvedFields();
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

          ],
        ),
      ),
    );
  }
}