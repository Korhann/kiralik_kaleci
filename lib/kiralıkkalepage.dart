import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class WhoAreWePage extends StatelessWidget {
  const WhoAreWePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground: background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white: Colors.black,),
        ),
      ),
      backgroundColor: userorseller ? sellerbackground: background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Halısahada kaleci bulmanın bu kadar zor olduğu zamanda,halısaha sevenler ile kalecileri bir araya getirmeyi amaçlıyoruz.',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: userorseller ? Colors.white: Colors.black
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}