import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/main.dart';
import 'package:kiralik_kaleci/styles/button.dart';

import 'styles/colors.dart';

class SignUp extends StatefulWidget {
  final VoidCallback? showLoginPage;
  const SignUp({super.key, required this.showLoginPage});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // The form key
  final formkey = GlobalKey<FormState>();

  // The text style for header
  final style = const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black);
  final hintstyle =const TextStyle(fontSize: 20, fontWeight: FontWeight.normal);
  final errorstyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.red);

  // To get variables from the user
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the UID of the newly created user
      String uid = userCredential.user!.uid;

      // Add the user to firestore with the obtained UID
      addUser(fullNameController.text.trim(), emailController.text.trim(), uid);

      // Navigate to the desired page (you can customize this part)
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyApp()));
    }
  } catch (e) {
    if (e is PlatformException) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _emailInUse = true;
        });
      }
    }
  }
}

  bool samePassword() {
    // Check if the passwords are the same
    if (passwordController.text.trim() ==
        confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                
                    // Header
                    Text(
                      "Kayıt Ol",
                      style: GoogleFonts.inter(
                        textStyle: style,
                      ),
                    ),
                
                    const SizedBox(height: 55),
                
                    // Textfields
                      SizedBox(
                        height: 45,
                        width: 335,
                        child: TextFormField(
                          controller: fullNameController,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 20),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(
                                    20.0, 10.0, 20.0, 10.0),
                                hintText: "Ad Soyad",
                                hintStyle: GoogleFonts.inter(
                                    textStyle: hintstyle,
                                    fontSize: 20,
                                    color: grey),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(15.0)),
                                fillColor: const Color(0xFFE5E5E5),
                                filled: true),
                            validator: (value) {
                              final nameSurname = value?.trim();
                              if (nameSurname!.isEmpty || !RegExp(r'^[a-z A-Z]+$').hasMatch(nameSurname)) {
                                setState(() {
                                  _showErrorName = true;
                                });
                                return '';
                              } else {
                                setState(() {
                                  _showErrorName = false;
                                });
                                return null;
                              }
                            }),
                      ),
                
                    const SizedBox(height: 5),
                
                    if (_showErrorName)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Geçerli bir isim soyisim giriniz",
                        style: GoogleFonts.inter(
                          textStyle: errorstyle
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 17),
                
                      SizedBox(
                        height: 45,
                        width: 335,
                        child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
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
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(15.0)),
                                fillColor: const Color(0xFFE5E5E5),
                                filled: true),
                            validator: (value) {
                              final email = value?.trim();
                              if (email!.isEmpty || !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
                                setState(() {
                                  _showErrorEmail = true;
                                });
                                return '';
                              }else {
                                setState(() {
                                  _showErrorEmail = false;
                                });
                                return null;
                              }
                          }
                        ),
                      ),
                
                    const SizedBox(height: 5),

                    // Email başka bir hesap tarafından kullanımda olmasına rağmen hata vermiyor.
                    if (_showErrorEmail || _emailInUse )
                      Align(
                        alignment: Alignment.centerLeft,
                      child: Text(
                        "Girdiğiniz mail hatalı veya kullanımda",
                        textAlign: TextAlign.start,
                        style: GoogleFonts.inter(
                          textStyle: errorstyle
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 17),
                
                    
                       SizedBox(
                        height: 45,
                        width: 335,
                        child: TextFormField(
                          controller: passwordController,
                          style:
                              const TextStyle(color: Colors.black, fontSize: 20),
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            hintText: "Parola",
                            hintStyle: GoogleFonts.inter(
                                textStyle: hintstyle, fontSize: 20, color: grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(15.0)),
                            fillColor: const Color(0xFFE5E5E5),
                            filled: true,
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
                
                    const SizedBox(height: 17),
                
                     SizedBox(
                        height: 45,
                        width: 335,
                        child: TextFormField(
                          controller: confirmPasswordController,
                          style:
                              const TextStyle(color: Colors.black, fontSize: 20),
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 10.0),
                              hintText: "Parola tekrar",
                              hintStyle: GoogleFonts.inter(
                                  textStyle: hintstyle,
                                  fontSize: 20,
                                  color: grey),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(15.0)),
                              fillColor: const Color(0xFFE5E5E5),
                              filled: true
                          ),
                          validator: (value) {
                            final repassword = value?.trim();
                            if (repassword!.isEmpty || confirmPasswordController.text.trim() != passwordController.text.trim()){
                              setState(() {
                                _showErrorRePassword = true;
                              });
                              return '';
                            }
                            else {
                              setState(() {
                                _showErrorRePassword = false;
                              });
                              return null;
                            }
                          },
                        ),
                      ),
                    
                    const SizedBox(height: 5),
                
                    if (_showErrorRePassword && passwordController.text.trim().isEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Parola boş bırakılamaz",
                        style: GoogleFonts.inter(
                          textStyle: errorstyle
                        ),
                      ),
                    ),
                    if (_showErrorRePassword && passwordController.text.trim() != confirmPasswordController.text.trim())
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Parola aynı olmalıdır",
                        style: GoogleFonts.inter(
                          textStyle: errorstyle
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 20.0),
                
                    // Text after the textfields
                       Row(
                        children: [
                          Text(
                            "Zaten bir hesabınız var mı?",
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: grey),
                          ),
                          const Spacer(),
                
                          /* DO NOT FORGET TO MAKE THE TEXT CLICKABLE!!! */
                          GestureDetector(
                            onTap: widget.showLoginPage,
                            child: Text(
                              "Giriş Yap",
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: green),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 50.0),
                
                    // The Kayıt Ol button
                    ElevatedButton(
                      style: buttonPrimary,
                      onPressed: () async{
                        if (formkey.currentState!.validate()) {
                          // Method to sign up the user
                          signUpUser();
                        }
                      },
                      child: Text(
                        "Kayıt Ol",
                        style: GoogleFonts.inter(
                            textStyle: style, color: Colors.black),
                      ),
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
