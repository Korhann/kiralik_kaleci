import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/mainpage.dart';
import 'package:kiralik_kaleci/styles/button.dart';

class CardDetails extends StatefulWidget {
  const CardDetails({super.key});

  // Flutter ın (flutter_credit_card) sayfasından package in sonundaki github kodunu kopyala ve birde onu dene

  @override
  State<CardDetails> createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> cardNumberKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> expiryDateKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> cardHolderKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> cvvCodeKey =
      GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          // there is a cannot add new events after calling close error
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              onCreditCardWidgetChange: (CreditCardBrand brand) {},
              obscureCardNumber: true,
              obscureCardCvv: true,
              enableFloatingCard: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CreditCardForm(
                      formKey: formKey, // Required
                      cardNumber: cardNumber, // Required
                      expiryDate: expiryDate, // Required
                      cardHolderName: cardHolderName, // Required
                      cvvCode: cvvCode, // Required
                      cardNumberKey: cardNumberKey,
                      cvvCodeKey: cvvCodeKey,
                      expiryDateKey: expiryDateKey,
                      cardHolderKey: cardHolderKey,
                      onCreditCardModelChange:
                          onCreditCardModelChange, // Required
                      obscureCvv: true,
                      obscureNumber: true,
                      isHolderNameVisible: true,
                      isCardNumberVisible: true,
                      isExpiryDateVisible: true,
                      enableCvv: true,
                      cvvValidationMessage: 'Please input a valid CVV',
                      dateValidationMessage: 'Please input a valid date',
                      numberValidationMessage: 'Please input a valid number',
                      cardNumberValidator: (String? cardNumber) {
                        if (cardNumber == null || cardNumber.isEmpty) {
                          return 'Bu alan zorunludur';
                        }
                        return null; // Return null if the validation passes
                      },
                      expiryDateValidator: (String? expiryDate) {
                        if (expiryDate == null || expiryDate.isEmpty) {
                          return 'Bu alan zorunludur';
                        }
                        // Add more validation logic if needed, e.g., check if it's a valid date
                        return null;
                      },
                      cvvValidator: (String? cvv) {
                        if (cvv == null || cvv.isEmpty) {
                          return 'Bu alan zorunludur';
                        }
                        // Add more validation logic if needed, e.g., check if it's a valid CVV
                        return null;
                      },
                      cardHolderValidator: (String? cardHolderName) {
                        if (cardHolderName == null || cardHolderName.isEmpty) {
                          return 'Bu alan zorunludur';
                        }
                        // Add more validation logic if needed
                        return null;
                      },
                      onFormComplete: () {
                        // callback to execute at the end of filling card data
                      },
                      autovalidateMode: AutovalidateMode.always,
                      disableCardNumberAutoFillHints: false,
                      inputConfiguration: const InputConfiguration(
                        cardNumberDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Kart Numarası',
                          hintText: 'XXXX XXXX XXXX XXXX',
                        ),
                        expiryDateDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Son Kullanım Tarihi',
                          hintText: 'XX/XX',
                        ),
                        cvvCodeDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'CVV',
                          hintText: 'XXX',
                        ),
                        cardHolderDecoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Kart Sahibi',
                        ),
                        cardNumberTextStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        cardHolderTextStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        expiryDateTextStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        cvvCodeTextStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: buttonPrimary,
                      onPressed: () async {
                        // Show loading screen while uploading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: SizedBox(
                                width: 10,
                                height: 40,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 5,
                                  ),
                                ),
                              ),
                            );
                          },
                        );

                        // Upload card details
                        bool success = await _insertCardDetails();

                        // Close loading screen
                        Navigator.pop(context);

                        // Navigate to MainPage if upload is successful
                        if (success) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MainPage()),
                          );
                        }
                      },
                      child: Text(
                        "Onayla",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onCreditCardModelChange(CreditCardModel creditCardModel) async {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Future<bool> _insertCardDetails() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

      if (userId.isNotEmpty) {
        Map<String, dynamic> cardDetails = {
          "cardNumber": cardNumber,
          "expiryDate": expiryDate,
          "cardHolderName": cardHolderName,
          "cvvCode": cvvCode,
        };

        await FirebaseFirestore.instance
            .collection("Users")
            .doc(userId)
            .update({"cardDetails": cardDetails});

        // Return true indicating successful upload
        return true;
      } else {
        print("Kullanıcı id si boş");
      }
    } catch (e) {
      print("Error: $e");
    }

    // Return false indicating upload failure
    return false;
  }
}
