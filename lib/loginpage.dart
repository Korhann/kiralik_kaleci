import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kiralik_kaleci/forgetpasswordpage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';


//TODO: ANİMASYON EKLENECEK !!!

class LogIn extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LogIn({super.key, required this.showRegisterPage});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  // text style for header
  final style = const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black);
  final hintstyle =const TextStyle(fontSize: 20, fontWeight: FontWeight.normal);
  final errorstyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red);

  final formkey = GlobalKey<FormState>();

  // email and password controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _showErrorEmail = false;
  bool _showErrorPassword = false;
  bool _invalidcred = false;

  // bool value for the password to show/hide
  //bool _obsecureText = true;

  // Initialize google
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // Changed the future with void!!
  Future signInUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());

    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        print('İnternet bağlantısı yok');
      } else if (e.code == 'wrong-password') {
        print('Şifreniz yanlış');
      } else if (e.code == 'user-not-found') {
        print('Email bulunamadı');
      } else if (e.code == 'invalid-credential') {
        setState(() {
          _invalidcred = true;
        });
        print('Girdiğiniz bilgiler geçersiz');
      }
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (error) {
      return null;
    }
  }

  void forgetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgetPassword(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formkey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 130),
              
                    // Header
                    PlatformText(
                      "Giriş Yap",
                      style: GoogleFonts.inter(
                        textStyle: style,
                      ),
                    ),
              
                    const SizedBox(height: 40),

                    GlobalStyles().buildTextField(emailController, "Email", _showErrorEmail, (value) {
                    setState(() => _showErrorEmail = value.trim().isEmpty ||!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value));
                  }),
              
                    const SizedBox(height: 10),
                    
                    GlobalStyles().buildTextField(passwordController, 'Parola', _showErrorPassword, (value) {
                    setState(() => _showErrorPassword = value.length < 6 || value.contains(" "));}, obscureText: true
                    ),
                    
                    
                    const SizedBox(height: 10),

                    if (_invalidcred)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: PlatformText(
                          'Girdiğiniz Bilgiler geçersizdir',
                          style: GoogleFonts.inter(
                            textStyle: errorstyle
                          ),
                        ),
                      ),
              
                    const SizedBox(height: 40),
              
                    // Giriş yap butonu
                    PlatformElevatedButton(
                      onPressed: () async{
                        if (formkey.currentState!.validate()) {
                          print('validating');
                          await signInUser();
                        }
                      },
                      child: Text(
                        "Giriş Yap",
                        style: GoogleFonts.inter(
                            textStyle: style, color: Colors.black),
                      ),
                      material: (_,__) => MaterialElevatedButtonData(
                        style: GlobalStyles.buttonPrimary()
                      ),
                      cupertino: (_,__) => CupertinoElevatedButtonData(
                        borderRadius: BorderRadius.circular(20),
                        color: green,
                        originalStyle: true
                      ),
                    ),

                    const SizedBox(height: 20),
              
                    GestureDetector(
                      onTap: () async{
                        forgetPassword();
                      },
                      child: PlatformText(
                        "Şifremi unuttum?",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: grey
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 20),
              
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await signInWithGoogle();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 25,
                                width: 25,
                                child: Image.asset("lib/icons/google.png"),
                              ),
                              const SizedBox(width: 10),
                              PlatformText(
                                "Google",
                                style: GoogleFonts.inter(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              
                    const SizedBox(height: 30),
              
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PlatformText(
                          "Bir hesabın yok mu?",
                          style: GoogleFonts.inter(
                              color: grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: widget.showRegisterPage,
                          child: PlatformText(
                            "Kayıt Ol",
                            style: GoogleFonts.inter(
                                decoration: TextDecoration.underline,
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
