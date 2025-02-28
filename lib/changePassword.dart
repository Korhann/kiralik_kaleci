import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

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
                color: userorseller ? sellergrey : background,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildTextField(_currentPasswordController, "Parola", _showErrorPassword, (value) {
                    setState(() => _showErrorPassword = value.length < 6 || value.contains(" "));
                  }, obscureText: true)
                ),
              ),
              
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
                color: userorseller ? sellergrey : background,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildTextField(_newPasswordController, "Parola tekrar", _showErrorNewPassword, (value) {
                    setState(() => _showErrorPassword = value.length < 6 || value.contains(" "));
                  }, obscureText: true)
                ),
              ),
                
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async{
                    if (_key.currentState!.validate()) {
                      print('1');
                      if (await InternetConnection().hasInternetAccess) {
                        print('2');
                        await changePassword();
                        showSuccessAlert('Başarılı');
                      } else {
                        if (mounted) {
                        showErrorAlert('Oopps...');
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
            validator(value!);
            return showError ? 'Geçerli bir $hintText giriniz' : null;
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

  /*
  MEVCUT ŞİFRELER
   Krhndmr2002
  */

  Future<void> changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      final cred = EmailAuthProvider.credential(email: user.email.toString(), password: _currentPasswordController.text);

      try {
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(_newPasswordController.text.trim());
        print('wow this is working');
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
void showSuccessAlert(String text) {
    QuickAlert.show(context: context, text: text,type: QuickAlertType.success,confirmBtnText: 'Tamam',title: 'Başarılı');
  }
  void showErrorAlert(String text) {
    QuickAlert.show(context: context, text: text,type: QuickAlertType.error,confirmBtnText: 'Tamam',title: 'Bir şeyler ters gitti');
  }
}
