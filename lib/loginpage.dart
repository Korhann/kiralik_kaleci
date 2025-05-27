import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kiralik_kaleci/forgetpasswordpage.dart';
import 'package:kiralik_kaleci/signuppage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:kiralik_kaleci/userorseller.dart';


//TODO: ANİMASYON EKLENECEK !!!

class LogIn extends StatefulWidget {
  const LogIn({super.key});

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

  // Initialize google
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _obsecureText = true;


  // Changed the future with void!!
  Future<void> signInUser() async {
    saveUserType('user');
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
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

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
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 100
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight
                ),
                child: Center(
                child: Form(
                key: formkey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 100),
                
                      // Header
                      PlatformText(
                        "Giriş Yap",
                        style: GoogleFonts.inter(
                          textStyle: style,
                        ),
                      ),
                
                      const SizedBox(height: 40),
                      
                       SizedBox(
                        width: width,  
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                          decoration: GlobalStyles.inputDecoration1(hintText: 'Email',showError: _showErrorEmail),
                          validator: (value) {
                            final email = value?.trim();
                            if (email!.isEmpty || !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
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
                
                      if (_showErrorEmail) 
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Girdiğiniz mail hatalı',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.inter(
                              textStyle: errorstyle
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: width,
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          obscureText: _obsecureText,
                          controller: passwordController,
                          style: const TextStyle(color: Colors.black, fontSize: 20),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            hintText: 'Parola',
                            hintStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.normal, color: grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: _showErrorPassword ? Colors.red : Colors.black),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: _showErrorPassword ? Colors.red : Colors.black),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red), // Error border when unfocused
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red), // Error border when focused
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            fillColor: const Color(0xFFE5E5E5),
                            filled: true,
                            errorStyle: const TextStyle(height: 0),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                // I have to change the icon size and add it to sign up page as well
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obsecureText = !_obsecureText;
                                    });
                                  },
                                  child: Image.asset(
                                    _obsecureText
                                        ? "lib/icons/eye.png"
                                        : "lib/icons/eye-off.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                ),
                              )
                            ),
                          validator: (value) {
                            final password = value?.trim();
                            if (password!.isEmpty || password.length < 6 || password.contains(" ")) {
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
                      const SizedBox(height: 5),
                
                      if (_showErrorPassword && passwordController.text.trim().length < 6)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Parolanın çok kısa",
                            style: GoogleFonts.inter(
                              textStyle: errorstyle
                            ),
                          ),
                        ),
                    
                      if (_showErrorPassword && passwordController.text.trim().contains(" "))
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Parolada boşluk bulundurmayınız",
                            style: GoogleFonts.inter(
                              textStyle: errorstyle
                            ),
                          ),
                        ),
                      if (_showErrorPassword && passwordController.text.trim().isEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Parola boş bırakılamaz",
                            style: GoogleFonts.inter(
                              textStyle: errorstyle
                            ),
                          ),
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
                            // await Firebaseanalytics().firebasePaymentNotification('sjfl', 'sfls');
                            await signInUser();
                          }
                        },
                        child: Text(
                          "Giriş Yap",
                          style: GoogleFonts.inter(
                              textStyle: style, color: Colors.black),
                        ),
                        material: (_,__) => MaterialElevatedButtonData(
                          style: GlobalStyles.buttonPrimary(context)
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
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                            },
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
            );
          }
        ),
      ),
    );
  }
}
