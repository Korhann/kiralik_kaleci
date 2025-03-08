import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kiralik_kaleci/approvedfield.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class ApprovedFields extends StatefulWidget {
  const ApprovedFields({super.key});

  @override
  State<ApprovedFields> createState() => _ApprovedFieldsState();
}

class _ApprovedFieldsState extends State<ApprovedFields> {

  List<ApprovedField> approvedFields = [];

  @override
  void initState() { 
    super.initState();
    getApprovedFields();
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