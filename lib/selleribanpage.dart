import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/styles/button.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class SellerIbanPage extends StatefulWidget {
  const SellerIbanPage({super.key});

  @override
  State<SellerIbanPage> createState() => SellerIbanPageState();
}

class SellerIbanPageState extends State<SellerIbanPage> {

  final formkey = GlobalKey<FormState>();
  
  final _ibanController = TextEditingController();
  final _nameController = TextEditingController();
  final _ibanFocusNode = FocusNode();
  
  bool wrongIBAN = false;
  bool wrongName = false;

  final String _ibanPattern = r'^TR\d{2} \d{4} \d{4} \d{4} \d{4} \d{4} \d{2}$';

  @override
  void initState() {
    super.initState();
    _ibanController.text = 'TR';
    _ibanFocusNode.addListener(() {
      if (_ibanFocusNode.hasFocus && !_ibanController.text.startsWith('TR')) {
        _ibanController.text = 'TR';
        _ibanController.selection = TextSelection.fromPosition(TextPosition(offset: _ibanController.text.length));
      }
    });
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String formatIban(String input) {
    input = input.replaceAll(' ', '').toUpperCase();
    StringBuffer formatted = StringBuffer();

    if (input.startsWith('TR')) {
      formatted.write('TR');
      input = input.substring(2);
    }

    for (int i = 0; i < input.length; i++) {
      if ((i == 2 || (i > 2 && (i - 2) % 4 == 0)) && i != 0) {
        formatted.write(' ');
      }
      formatted.write(input[i]);
    }

    return formatted.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sellerbackground,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white)
        ),
      ),
      backgroundColor: sellerbackground,
      body: SafeArea(
        child: Form(
          key: formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'IBAN no',
                  style: GoogleFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: sellergrey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    style: const TextStyle(
                      color: Colors.white
                    ),
                    controller: _ibanController,
                    focusNode: _ibanFocusNode,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(32), // Including spaces
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9 ]')),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        String newText = newValue.text.toUpperCase();
                        if (newText.startsWith('TR') && newText.length > 2) {
                          newText = 'TR' + formatIban(newText.substring(2));
                        } else if (!newText.startsWith('TR')) {
                          newText = 'TR' + formatIban(newText);
                        } else {
                          newText = formatIban(newText);
                        }

                        TextSelection newSelection = newValue.selection;
                        if (newSelection.start <= 2) {
                          newSelection = newSelection.copyWith(
                            baseOffset: 2,
                            extentOffset: 2,
                          );
                        }

                        return TextEditingValue(
                          text: newText,
                          selection: newSelection,
                        );
                      }),
                    ],
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          wrongIBAN = true;
                        });
                        return 'Zorunlu alan boş bırakılmaz';
                      }
                      final regex = RegExp(_ibanPattern);
                      if (!regex.hasMatch(value)) {
                        setState(() {
                          wrongIBAN = true;
                        });
                        return 'Lütfen geçerli bir iban giriniz';
                      }
                      setState(() {
                        wrongIBAN = false;
                      });
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'İban Sahibinin Adı',
                  style: GoogleFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: sellergrey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    style: const TextStyle(
                      color: Colors.white
                    ),
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          wrongName = true;
                        });
                        return 'Zorunlu alandır boş bırakılmaz';
                      }
                      setState(() {
                        wrongName = false;
                      });
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 60),

              Center(
                child: ElevatedButton(
                  onPressed: () async{
                    if (formkey.currentState!.validate()) {
                      await _updateIbanNo();
                    }
                  },
                  style: buttonPrimary,
                  child: Text(
                    'Kaydet',
                    style: GoogleFonts.roboto(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white
                    ),
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateIbanNo() async{
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isNotEmpty) {
      String iban = _ibanController.text;
      String name = _nameController.text;

      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      );
      try {
        Map<String, dynamic> ibanDetails = {
          'ibanNo': iban,
          'name': name
        };

        await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(userId)
          .update({'ibanDetails': ibanDetails});
        _ibanController.clear();
        _nameController.clear();

        Navigator.of(context).pop();

      } catch (e) {
        print('Error $e');
      } finally {
        Navigator.of(context).pop();
      }
    }
  }
}