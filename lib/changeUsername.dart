import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';

class SellerChangeUserName extends StatefulWidget {
  const SellerChangeUserName({super.key});

  @override
  State<SellerChangeUserName> createState() => _SellerChangeUserNameState();
}

class _SellerChangeUserNameState extends State<SellerChangeUserName> {
  final _key = GlobalKey<FormState>();
  final _newUsername = TextEditingController();
  final errorstyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red);
  bool _showErrorUsername = false;

  @override
  void dispose() {
    _newUsername.dispose();
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
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Yeni Kullanıcı Adı',
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
                color: userorseller ? sellergrey : background,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    decoration: GlobalStyles.inputDecoration(hintText: 'Ad Soyad'),
                    style: TextStyle(color: userorseller ? Colors.white : Colors.black),
                    controller: _newUsername,
                    onChanged: (value) => clearErrors(),
                    validator: (value) {
                      final trimmedValue = value?.trim();
                      if (trimmedValue == null || trimmedValue.isEmpty || trimmedValue.length < 6) {
                        setState(() {
                          _showErrorUsername = true;
                        });
                        return '';
                      } else {
                        setState(() {
                          _showErrorUsername = false;
                        });
                        return null;
                      }
                    },
                  ),
                ),
              ),
              if (_showErrorUsername && _newUsername.text.trim().isEmpty)
                errorMessage('Kullanıcı adı boş bırakılamaz'),
              if (_showErrorUsername && _newUsername.text.trim().length < 6)
                errorMessage('Kullanıcı adı 6 haneden uzun olmalı'),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async{
                    if (_key.currentState!.validate()) {
                      if (await InternetConnection().hasInternetAccess) {
                        changeUsername();
                        if (mounted) {
                          Showalert(context: context, text: 'Güncelleme Başarılı').showSuccessAlert();
                        }
                      } else {
                      if (mounted) {
                        Showalert(context: context, text: 'Ooops...').showErrorAlert();
                      }
                      }
                    }
                  },
                  style: GlobalStyles.buttonPrimary(),
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

  void clearErrors() {
    setState(() {
      _showErrorUsername = false;
    });
  }

  void changeUsername() async {
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    if (currentuser != null) {
      try {
        await FirebaseFirestore.instance.collection('Users')
          .doc(currentuser)
          .update({
          'fullName': _newUsername.text.trim()
        });
      } catch (e) {
        print('Error updating username $e');
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
            'Kullanıcı adı başarı ile güncellenmiştir',
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
