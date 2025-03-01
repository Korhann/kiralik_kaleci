import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'styles/colors.dart';
import 'mainpage.dart';

//TODO: ANİMASYON EKLENECEK !!!

class SignUp extends StatefulWidget {
  final VoidCallback? showLoginPage;
  const SignUp({super.key, required this.showLoginPage});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formkey = GlobalKey<FormState>();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final style = const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black);

  bool _showErrorName = false;
  bool _showErrorEmail = false;
  bool _showErrorPassword = false;
  bool _showErrorRePassword = false;
  bool _emailInUse = false;

  Future signUpUser() async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      if (samePassword()) {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String uid = userCredential.user!.uid;
        addUser(fullNameController.text.trim(), email, uid);

        Navigator.push(context, platformPageRoute(builder: (_) => const MainPage(), context: (context)));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _emailInUse = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  bool samePassword() {
    return passwordController.text.trim() == confirmPasswordController.text.trim();
  }

  Future addUser(String fullName, String email, String uid) async {
    await FirebaseFirestore.instance.collection("Users").doc(uid).set({
      "fullName": fullName,
      "email": email,
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  PlatformText(
                    "Kayıt Ol",
                    style: GoogleFonts.inter(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 55),

                  GlobalStyles().buildTextField(fullNameController, "Ad Soyad", _showErrorName, (value) {
                    setState(() => _showErrorName = value.trim().isEmpty || !RegExp(r'^[a-zA-Z ]+$').hasMatch(value));
                  }),

                  GlobalStyles().buildTextField(emailController, "Email", _showErrorEmail || _emailInUse, (value) {
                    setState(() => _showErrorEmail = value.trim().isEmpty ||
                        !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value));
                  }),

                  GlobalStyles().buildTextField(passwordController, "Parola", _showErrorPassword, (value) {
                    setState(() => _showErrorPassword = value.length < 6 || value.contains(" "));
                  }, obscureText: true),

                  GlobalStyles().buildTextField(confirmPasswordController, "Parola tekrar", _showErrorRePassword, (value) {
                    setState(() => _showErrorRePassword = value != passwordController.text.trim());
                  }, obscureText: true),

                  const SizedBox(height: 20.0),

                  Row(
                    children: [
                      PlatformText(
                        "Zaten bir hesabınız var mı?",
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: grey),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.showLoginPage,
                        child: PlatformText(
                          "Giriş Yap",
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: green),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50.0),

                  PlatformElevatedButton(
                    onPressed: () async {
                      if (formkey.currentState!.validate()) {
                        print('just controlling');
                        signUpUser();
                      }
                    },
                    child: PlatformText("Kayıt Ol", style: GoogleFonts.inter(color: Colors.black, textStyle: style)),
                    material: (_, __) => MaterialElevatedButtonData(style: GlobalStyles.buttonPrimary()),
                    cupertino: (_, __) => CupertinoElevatedButtonData(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
