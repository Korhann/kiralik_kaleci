import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground: background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
        }, 
        icon: Icon(Icons.arrow_back,color: userorseller ? Colors.white: Colors.black)),
      ),
      backgroundColor: userorseller ? sellerbackground: background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adres: Üsküdar/Aziz Mahmut Hüdayii mah. Davutoğlu sokak',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: userorseller ? Colors.white: Colors.black
                      ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'İletişim: 0541 522 14 89',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: userorseller ? Colors.white: Colors.black
                      ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Mail: kiraliikkalecii@gmail.com',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: userorseller ? Colors.white: Colors.black
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}