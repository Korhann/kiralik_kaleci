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
        backgroundColor: userorseller ? sellerbackground: background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white: Colors.black)
        ),
      ),
      backgroundColor: userorseller ? sellerbackground: background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SellerChangeUserName())
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: userorseller ? sellergrey: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Kullanıcı Adı Değiştir',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: userorseller ? Colors.white: Colors.black
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward,
                        size: 24,
                        color: userorseller ? Colors.white: Colors.black,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color: sellerwhite,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SellerChangePassword())
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: userorseller ? sellergrey: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Şifre Değiştir',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: userorseller ? Colors.white: Colors.black
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward,
                        size: 24,
                        color: userorseller ? Colors.white: Colors.black,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color: sellerwhite,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangeEmail())
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: userorseller ? sellergrey: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Email Değiştir',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: userorseller ? Colors.white: Colors.black
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward,
                        size: 24,
                        color: userorseller ? Colors.white: Colors.black,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}