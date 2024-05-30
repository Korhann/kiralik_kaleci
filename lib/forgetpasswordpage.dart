import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/styles/button.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  // Key for the form
  final formkey = GlobalKey<FormState>();
  // Textstyles
  final hintstyle =const TextStyle(fontSize: 20, fontWeight: FontWeight.normal);
  final style = const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black);
  final textstyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.normal);
  final errorstyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red);

  // Declare the contorller
  final resetController = TextEditingController();

  // Added variable to control error message visibility
  bool _showError = false; 

  Future<void> sendResetLink() async {
    final textResetController = resetController.text.trim();
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: textResetController);
  }

  @override
  void dispose() {
    super.dispose();
    resetController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              children: [
                const SizedBox(height: 160),
                Text(
                  "Şifreni yenile",
                  style: GoogleFonts.inter(textStyle: style),
                ),


                const SizedBox(height: 40),



                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Email giriniz ve hesabınıza şifrenizi yenilemek için link gönderilecek",
                    textAlign: TextAlign.start,
                    style: GoogleFonts.inter(textStyle: textstyle, color: grey),
                  ),
                ),


                const SizedBox(height: 30),


                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 5.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 45,
                        width: 335,
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: resetController,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 10.0, 20.0, 10.0),
                            hintText: "Email",
                            hintStyle: GoogleFonts.inter(
                                textStyle: hintstyle,
                                fontSize: 20,
                                color: grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            fillColor: const Color(0xFFE5E5E5),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value!.isEmpty || !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                              setState(() {
                                _showError = true;
                              });
                              return null;
                            } else {
                              setState(() {
                                _showError = false;
                              });
                              return null;
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 5),


                      if (_showError)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Geçerli bir mail adresi giriniz",
                            style: GoogleFonts.inter(
                              textStyle: errorstyle
                            ),
                          ),
                        ),
                    ],
                  ),
                ),


                const SizedBox(height: 30),



                ElevatedButton(
                  style: buttonPrimary,
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      sendResetLink();
                    }
                  },
                  child: Text(
                    "Yenile",
                    style: GoogleFonts.inter(textStyle: style),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
