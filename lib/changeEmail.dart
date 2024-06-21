import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/button.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({super.key});

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {

  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  //
  final _key = GlobalKey<FormState>();
  //
  bool _showErrorEmail = false;
  bool _showErrorPassword = false;
  //
  String _reauthErrorMessage = '';
  //
  final errorstyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red);

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
      body: Form(
        key: _key,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Yeni Email',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: userorseller ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                color: userorseller ? sellergrey : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    style: TextStyle(color: userorseller ? Colors.white : Colors.black),
                    controller: _emailController,
                    obscureText: false,
                    onChanged: (value) => clearErrors(),
                    validator: (value) {
                      final currentTrimmedemail = value?.trim();
                      if (currentTrimmedemail!.isEmpty || !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(currentTrimmedemail)) {
                        setState(() {
                          _showErrorEmail = true;
                        });
                        return '';
                      } else {
                        setState(() {
                          _showErrorEmail = false;
                        });
                        return null;
                      }
                    },
                  ),
                ),
              ),
              if (_showErrorEmail) 
                errorMessage('Girdiğiniz mail hatalı veya kullanımda'),

              const SizedBox(height: 30),
              
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Mevcut Şifre',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: userorseller ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                color: userorseller ? sellergrey : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    style: TextStyle(color: userorseller ? Colors.white : Colors.black),
                    controller: _currentPasswordController,
                    obscureText: true,
                    onChanged: (value) => clearErrors(),
                    validator: (value) {
                      final currentTrimmedPassword = value?.trim();
                      if (currentTrimmedPassword!.isEmpty || currentTrimmedPassword.length < 6 || currentTrimmedPassword.contains(" ")) {
                        setState(() {
                          _showErrorPassword = true;
                        });
                        return '';
                      } else {
                        setState(() {
                          _showErrorPassword = false;
                        });
                        return null;
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_key.currentState!.validate()) {
                      changeEmail();
                    }
                  },
                  style: buttonPrimary,
                  child: Text(
                    'Onayla',
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: userorseller ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  void clearErrors() {
    setState(() {
      _showErrorEmail = false;
      _reauthErrorMessage = '';
    });
  }
  
  Widget errorMessage(String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          message,
          style: GoogleFonts.inter(textStyle: errorstyle),
        ),
      ),
    );
  }

  void changeEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    String email = _emailController.text.trim();
    String password = _currentPasswordController.text.trim();
    if (user != null && user.email != null) {
      final cred = EmailAuthProvider.credential(email: user.email.toString(), password: password);
      try {
        await user.reauthenticateWithCredential(cred);
        // bu yeni güncellenen mail
        // hata yazısına dikkatlice bak anlamaya çalış
        await user.verifyBeforeUpdateEmail(email);
        await FirebaseFirestore.instance.collection('Users')
          .doc(currentuser)
          .update({
          'email': email
        });
        await showBottomSheetDialog(context);
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _reauthErrorMessage = 'Geçerli bir mail giriniz';
        });
        print("Error updating email: $e");
      }
    } else {
      setState(() {
        _reauthErrorMessage = 'Kullanıcı oturumu açılmadı';
      });
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
              'Mailin güncellenmesi için onay kodunu onaylayın',
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
    await Future.delayed(const Duration(seconds: 1));
  }
}
