import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/authpage.dart';
import 'package:kiralik_kaleci/directmessages.dart';
import 'package:kiralik_kaleci/homepage.dart';
import 'package:kiralik_kaleci/profilepage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Stream<User?> _authStream;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
  }


@override
Widget build(BuildContext context) {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  return StreamBuilder<User?>(
    stream: _authStream,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        // kullanıcı giriş yaptı
        return Scaffold(
          body: screens()[_currentIndex],
          bottomNavigationBar: BottomNavyBar(
            backgroundColor: background,
            selectedIndex: _currentIndex,
            onItemSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavyBarItem(
                icon: const Icon(
                  Icons.home,
                  color: Colors.black
                ),
                title: Text(
                  'Ana Sayfa',
                  style: GoogleFonts.inter(
                    color: Colors.black
                  ),
                ),
              ),
              BottomNavyBarItem(
                icon: const Icon(
                  Icons.mail,
                  color: Colors.black,
                ),
                title:  Text(
                  'Mesajlar',
                  style: GoogleFonts.inter(
                    color: Colors.black
                  ),
                ),
              ),
              BottomNavyBarItem(
                icon: const Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                title:  Text(
                  'Profil',
                  style: GoogleFonts.inter(
                    color: Colors.black
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // kullanıcı giriş yapmadı demek
        return const AuthPage();
      }
    },
  );
}

  List<Widget> screens() {
    return [const HomePage(), const DirectMessages(), const ProfilePage()];
  }
}
