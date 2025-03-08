import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/changeEmail.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/changePassword.dart';
import 'package:kiralik_kaleci/changeUsername.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground : background,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,
                color: userorseller ? Colors.white : Colors.black)),
      ),
      backgroundColor: userorseller ? sellerbackground : background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            Menus(text: 'Kullanıcı Adı Değiştir', route: MaterialPageRoute(builder: (context) => const ChangeUserName())),

            Container(
              height: 1,
              color: sellerwhite,
            ),

            Menus(text: 'Şifre Değiştir', route: MaterialPageRoute(builder: (context) => const ChangePassword())),

            Container(
              height: 1,
              color: sellerwhite,
            ),

            Menus(text: 'Email Değiştir', route: MaterialPageRoute(builder: (context) => const ChangeEmail()))

          ],
        ),
      ),
    );
  }
}

class Menus extends StatelessWidget {

  final String text;
  final Route route;

  const Menus({required this.text, required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, route);
      },
      child: Container(
        height: 50,
        width: double.infinity,
        color: userorseller ? sellergrey : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                text,
                style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: userorseller ? Colors.white : Colors.black),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward,
                size: 24,
                color: userorseller ? Colors.white : Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}
