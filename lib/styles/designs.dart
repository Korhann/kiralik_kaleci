import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class GlobalStyles {
  static InputDecoration inputDecoration({required String hintText}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: Colors.grey,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(15.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(15.0),
      ),
      fillColor: const Color(0xFFE5E5E5),
      filled: true,
    );
  }
  static ButtonStyle buttonPrimary() {
    return ElevatedButton.styleFrom(
      minimumSize: const Size(335, 55),
      backgroundColor: green, // Your custom green color
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
    );
  }
}
