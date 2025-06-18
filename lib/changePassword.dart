import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/button.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class SellerChangePassword extends StatefulWidget {
  const SellerChangePassword({super.key});

  @override
  State<SellerChangePassword> createState() => _SellerChangePasswordState();
}

class _SellerChangePasswordState extends State<SellerChangePassword> {
  // Controllers for passwords
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  // Form key
  final _key = GlobalKey<FormState>();
  // Error flags
  bool _showErrorPassword = false;
  bool _showErrorNewPassword = false;

  String _reauthErrorMessage = '';
  final errorstyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
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
              if (_showErrorPassword && _currentPasswordController.text.trim().length < 6)
                errorMessage("Parolanız çok kısa"),
              if (_showErrorPassword && _currentPasswordController.text.trim().contains(" "))
                errorMessage("Parolada boşluk bulundurmayınız"),
              if (_showErrorPassword && _currentPasswordController.text.trim().isEmpty)
                errorMessage("Parola boş bırakılamaz"),
              if (_reauthErrorMessage.isNotEmpty)
                errorMessage(_reauthErrorMessage),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Yeni Şifre',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: userorseller ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: userorseller ? sellergrey : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    style: TextStyle(color: userorseller ? Colors.white : Colors.black),
                    controller: _newPasswordController,
                    obscureText: true,
                    onChanged: (value) => clearErrors(),
                    validator: (value) {
                      final newTrimmedPassword = value?.trim();
                      if (newTrimmedPassword!.isEmpty || newTrimmedPassword.length < 6 || newTrimmedPassword.contains(" ")) {
                        setState(() {
                          _showErrorNewPassword = true;
                        });
                        return null;
                      } else {
                        setState(() {
                          _showErrorNewPassword = false;
                        });
                        return null;
                      }
                    },
                  ),
                ),
              ),
              if (_showErrorNewPassword && _newPasswordController.text.trim().length < 6)
                errorMessage("Parolanız çok kısa"),
              if (_showErrorNewPassword && _newPasswordController.text.trim().contains(" "))
                errorMessage("Parolada boşluk bulundurmayınız"),
              if (_showErrorNewPassword && _newPasswordController.text.trim().isEmpty)
                errorMessage("Parola boş bırakılamaz"),
                
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_key.currentState!.validate()) {
                      changePassword();
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

  /*
  MEVCUT ŞİFRELER
   Krhndmr2002
  */

  void changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      final cred = EmailAuthProvider.credential(email: user.email.toString(), password: _currentPasswordController.text);

      try {
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(_newPasswordController.text.trim());
        await showBottomSheetDialog(context);
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _reauthErrorMessage = 'Geçerli bir şifre giriniz';
        });
      }
    }
  }
  void clearErrors() {
    setState(() {
      _showErrorPassword = false;
      _showErrorNewPassword = false;
      _reauthErrorMessage = '';
    });
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
            'Kullanıcı şifresi başarı ile güncellenmiştir',
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
