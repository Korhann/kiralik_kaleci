import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/authpage.dart';
import 'package:kiralik_kaleci/directmessages.dart';
import 'package:kiralik_kaleci/homepage.dart';
import 'package:kiralik_kaleci/profilepage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.index
    });

  final int index;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Stream<User?> _authStream;
  int _currentIndex = 0;
  String currentUser = FirebaseAuth.instance.currentUser!.uid;
  int _unreadMessages = 0;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
    _currentIndex = widget.index;
    listenToUnreadCount();
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
                icon: Stack(
                children: [
                  const Icon(Icons.mail,color: Colors.black),
                  if (_unreadMessages > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                        child: Text(
                          '$_unreadMessages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ],
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

  void listenToUnreadCount() async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? sharedIds = prefs.getStringList('ids');
  if (sharedIds == null) return;

  Map<String, int> unreadPerChat = {};

  for (var st in sharedIds) {
    List<String> ids = [currentUser, st];
    ids.sort();
    String chatRoomId = ids.join('_');

    FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc('meta')
        .snapshots()
        .listen((metaDoc) {
      final data = metaDoc.data();
      if (data == null) return;

      int unread = data['senderId'] == currentUser ? data['to_msg'] ?? 0 : data['from_msg'] ?? 0;
      unreadPerChat[chatRoomId] = unread;

      // Recalculate total
      int totalUnread = unreadPerChat.values.fold(0, (a, b) => a + b);

      setState(() {
        _unreadMessages = totalUnread;
      });
    });
  }
}
}
