import "package:flutter/material.dart";
import "package:kiralik_kaleci/loginpage.dart";
import "package:kiralik_kaleci/signuppage.dart";

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  bool showLoginPage = true;

  void toggleScreens(){
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage){
      return LogIn();
    } else{
      return SignUp();
    }
  }
}