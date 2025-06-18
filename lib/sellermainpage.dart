import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/selleraddpage.dart';
import 'package:kiralik_kaleci/sellerdirectmessages.dart';
import 'package:kiralik_kaleci/sellerprofilepage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class SellerMainPage extends StatefulWidget {
  const SellerMainPage({super.key});

  @override
  State<SellerMainPage> createState() => SellerMainPageState();
}

class SellerMainPageState extends State<SellerMainPage> {

  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens()[_currentIndex],
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: sellerbackground,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavyBarItem(
            icon: const Icon(Icons.home,color: Colors.white,),
            title: const Text('Ana Sayfa'),
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.mail,color: Colors.white),
            title: const Text('Mesajlar'),
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.person,color: Colors.white),
            title: const Text('Profil'),
          ),
        ],
      ),
    );
  }
  List<Widget> screens() {
    return [const SellerAddPage(), const SellerDirectMessages(), const SellerProfilePage()];
  }
}
