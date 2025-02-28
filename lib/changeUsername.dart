import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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

  final formkey = GlobalKey<FormState>();
  TextEditingController newUsername = TextEditingController();
  final errorstyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red);
  bool _showErrorUsername = false;

  @override
  void dispose() {
    super.dispose();
    newUsername.dispose();
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
        key: formkey,
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
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                color: userorseller ? sellergrey : background,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildTextField(newUsername, "Ad Soyad", _showErrorUsername, (value) {
                    setState(() => _showErrorUsername = value.trim().isEmpty || value.isEmpty ||!RegExp(r'^[a-zA-Z ]+$').hasMatch(value));
                  }),
                ),
              ),
              
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async{
                    if (formkey.currentState!.validate()) {
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
  Widget _buildTextField(
  TextEditingController controller,
  String hintText,
  bool showError,
  Function(String) validator, {
  bool obscureText = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 45,
        width: 335,
        child: PlatformTextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black, fontSize: 20),
          material: (_, __) => MaterialTextFormFieldData(
            decoration: GlobalStyles.inputDecoration1(hintText: hintText,showError:  showError),
          ),
          cupertino: (_, __) => CupertinoTextFormFieldData(
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: showError ? Colors.red : Colors.black), // Keep style but change border color
            ),
            placeholder: hintText,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          validator: (value) {
            bool isValid = value!.trim().isNotEmpty && RegExp(r'^[a-zA-Z ]+$').hasMatch(value);
            if (!isValid) {
              setState(() {
                _showErrorUsername = true; 
              });
              return ''; // Empty string to trigger custom error display
            }
            setState(() {
              _showErrorUsername = false; // Clear error if valid
            });
              return null;
          },

        ),
      ),
      const SizedBox(height: 10,),
      if (showError)
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: PlatformText(
            "Geçerli bir $hintText giriniz",
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red),
          ),
        ),
      const SizedBox(height: 17),
    ],
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

  void changeUsername() async {
    final String? currentuser = FirebaseAuth.instance.currentUser?.uid;
    if (currentuser != null) {
      try {
        await FirebaseFirestore.instance.collection('Users')
          .doc(currentuser)
          .update({
          'fullName': newUsername.text.trim()
        });
        newUsername.clear(); // Clears the textfield after successful update
        setState(() => _showErrorUsername = false);
      } catch (e) {
        print('Error updating username $e');
      }
    }
  }
}
