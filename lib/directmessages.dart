import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/sharedvalues.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

import 'direct2messagepage.dart';

class DirectMessages extends StatefulWidget {
  const DirectMessages({Key? key}) : super(key: key);

  @override
  State<DirectMessages> createState() => _DirectMessagesState();
}

class _DirectMessagesState extends State<DirectMessages> {
  // sharedvalues dan gelen değerleri al
  String uid = sharedValues.sellerUid;

  String? sellerUserName;

  List<String> messages = [];
  List<String> receiverNames = [];
  List<String> distinctReceiverIds = [];

  // firebase instance oluştur
  String currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _getMessages();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: background,
    body: ListView.builder(
      itemCount: receiverNames.length,
      itemBuilder: (BuildContext context, int index) {
        // burası yapılacak
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0)
              const SizedBox(height: 40), 
            if (index == 0)
              Center(
                child: Column(
                  children: [
                    Text(
                      "Mesajlar",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20), 
                  ],
                ),
              ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Direct2Message(receiverId: distinctReceiverIds[index]),
                  ),
                );
              },
              child: ListTile(
                leading: FutureBuilder(
                  future: _getReceiverImage(distinctReceiverIds[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        // yükleniyor demek
                        backgroundColor: Colors.grey,
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const CircleAvatar(
                        // error verince
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.error),
                      );
                    } else {
                      return CircleAvatar(
                        // doğru çalışınca
                        backgroundImage: NetworkImage(snapshot.data as String),
                        radius: 25,
                      );
                    }
                  },
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiverNames[index],
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(messages[index]),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}


  Future<void> _getMessages() async {
    try {
      String currentUser = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot distinctSenderIdsSnapshot = await FirebaseFirestore.instance
          .collectionGroup('messages')
          .where('senderId', isEqualTo: currentUser)
          .get();

      distinctReceiverIds = distinctSenderIdsSnapshot.docs
          .map((doc) => doc['receiverId'] as String)
          .toSet() // duplicate olmaması için
          .toList();

      for (String receiverId in distinctReceiverIds) {
        QuerySnapshot latestMessageSnapshot = await FirebaseFirestore.instance
            .collectionGroup('messages')
            .where('senderId', isEqualTo: currentUser)
            .where('receiverId', isEqualTo: receiverId)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (latestMessageSnapshot.docs.isNotEmpty) {
          // chatteki en son mesajı al
          DocumentSnapshot latestMessageDoc = latestMessageSnapshot.docs.first;
          Map<String, dynamic> data = latestMessageDoc.data() as Map<String, dynamic>;

          String message = data['message'];
          // burada sender email yerine gönderdiğin kişinin ismini alıcaksın
          String receiverfullName = data['receiverfullName'];

          // mesajı ve ismi ekle
          setState(() {
            messages.add(message);
            receiverNames.add(receiverfullName);
          });
        }
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  Future<String?> _getReceiverImage(String receiverId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(receiverId)
          .get();

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      if (data.isNotEmpty && data.containsKey('sellerDetails') && data['sellerDetails'].containsKey('imageUrls')) {
        List<dynamic> imageUrls = data['sellerDetails']['imageUrls'];
        if (imageUrls.isNotEmpty) {
          return imageUrls.first;
        }
      }
    } catch (e) {
      print("Error fetching receiver image: $e");
    }
    return null; 
  }
}
