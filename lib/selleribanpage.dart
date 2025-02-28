import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';

class SellerIbanPage extends StatefulWidget {
  const SellerIbanPage({super.key});

  @override
  State<SellerIbanPage> createState() => SellerIbanPageState();
}

class SellerIbanPageState extends State<SellerIbanPage> {
  // TODO problem text i silince TR kısmında T ve R yazmaya başlıyor !!!

  final formkey = GlobalKey<FormState>();
  
  final _ibanController = TextEditingController();
  final _nameController = TextEditingController();
  final _ibanFocusNode = FocusNode();
  
  bool wrongIBAN = false;
  bool wrongName = false;

  final String _ibanPattern = r'^TR\d{2} \d{4} \d{4} \d{4} \d{4} \d{4} \d{2}$';


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
                    fontSize: 20,
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

  // Format the input while keeping "TR" at the start
  if (newText.startsWith('TR') && newText.length > 2) {
    newText = 'TR${formatIban(newText.substring(2))}';
  } else if (!newText.startsWith('TR')) {
    newText = 'TR${formatIban(newText)}';
  } else {
    newText = formatIban(newText);
  }

  // Calculate the correct cursor position
  int newSelectionIndex = newValue.selection.end;

  // Track spaces in the formatted IBAN
  int spaceCount = 'TR'.allMatches(newText).length;
  newSelectionIndex += spaceCount;

  // Make sure the cursor position is within bounds
  newSelectionIndex = newSelectionIndex.clamp(0, newText.length);

  // Return the updated TextEditingValue with adjusted cursor position
  return TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: newSelectionIndex),
  );
})
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
                    fontSize: 20,
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
                  style: GlobalStyles.buttonPrimary(),
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
        await showBottomSheetDialog(context);
        Navigator.of(context).pop();

      } catch (e) {
        print('Error $e');
      } finally {
        Navigator.of(context).pop();
      }
    }
  }
  Future<void> showBottomSheetDialog(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height: 80,
        padding: const EdgeInsets.all(16.0),
        color: userorseller ? sellerbackground : background,
        child: Center(
          child: Text(
            ' Iban numarası başarı ile güncellenmiştir',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: userorseller ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
    },
  );
  // Delay pop to give user time to see the confirmation message
  await Future.delayed(const Duration(seconds: 1));
}
}