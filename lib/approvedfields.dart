import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kiralik_kaleci/approvedfield.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:shimmer/shimmer.dart';

class ApprovedFields extends StatefulWidget {
  const ApprovedFields({super.key});

  @override
  State<ApprovedFields> createState() => _ApprovedFieldsState();
}

class _ApprovedFieldsState extends State<ApprovedFields> {

  List<ApprovedField> approvedFields = [];

  late Future<void> getFields;

  @override
  void initState() { 
    super.initState();
    getFields = getApprovedFields();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWithBackButton(
      child: FutureBuilder(
        future: getFields,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.only(top: 30),
              child: ApprovedFieldsShimmer()
            );
          }
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
      body: approvedFields.isEmpty ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
        itemCount: approvedFields.expand((field) => field.fields).length,
        itemBuilder: (context, index) {
          List<String> allFields = approvedFields.expand((field) => field.fields).toList();
          return showCardFields(allFields: allFields, index: index);
        },
      ),
    );
        }
      ) ,
    );
  }
  Future<void> getApprovedFields() async {
    await ApprovedField.approvedFields();
    var localDb = await Hive.openBox<ApprovedField>('approved_fields');
    setState(() {
      approvedFields = localDb.values.toList();
    });
  }
}
class showCardFields extends StatelessWidget {
  final List<String> allFields;
  final int index;
  const showCardFields({
    Key? key,
    required this.allFields,
    required this.index
  });

  @override
  Widget build(BuildContext context) {
    return Card(
            color: userorseller ? sellerbackground : Colors.white,
            child: ListTile(
              title: Text(
                allFields[index]
              ),
              leading: const Icon(Icons.sports_soccer_outlined),
            ),
          );
  }
}

class ApprovedFieldsShimmer extends StatelessWidget {
  const ApprovedFieldsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6, // You can adjust the placeholder count
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,  // Keep it clean on a white background
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              title: Container(
                height: 16,
                width: 150,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        );
      },
    );
  }
}