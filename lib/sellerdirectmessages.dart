import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/sellermessagepage.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'sharedvalues.dart';

class SellerDirectMessages extends StatefulWidget {
  const SellerDirectMessages({super.key});

  @override
  State<SellerDirectMessages> createState() => _SellerDirectMessagesState();
}

class _SellerDirectMessagesState extends State<SellerDirectMessages> {

  /*
  ŞUAN BURASI KULLANICININ GÖNDERDİĞİ MESAJLARI ALMIYOR !!
  MESAJ YAZMADAN MESAJLAR GELMİYOR
  */
  
  // sharedvalues dan gelen değerleri al
  String uid = sharedValues.sellerUid;

  String? sellerUserName;

  List<String> messages = [];
  List<String> senderNames = [];
  List<String> distinctSenderIds = [];

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
    backgroundColor: sellerbackground,
    body: ListView.builder(
      itemCount: senderNames.length,
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
                        color: Colors.white,
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
                    builder: (context) => SellerMessagePage(receiverId: distinctSenderIds[index]),
                  ),
                );
              },
              child: ListTile(
                leading: FutureBuilder(
                  // burada bir mantık hatası var !!
                  future: _getReceiverImage(distinctSenderIds[index]),
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
                      senderNames[index],
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                    ),
                    Text(
                      messages[index],
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                        color: Colors.white
                      ),
                    ),
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
          .where('receiverId', isEqualTo: currentUser)
          .get();

      distinctSenderIds = distinctSenderIdsSnapshot.docs
          .map((doc) => doc['senderId'] as String)
          .toSet() // duplicate olmaması için
          .toList();
      print("distinct sender ids are ${distinctSenderIds.length}");

      for (String senderId in distinctSenderIds) {
        QuerySnapshot latestMessageSnapshot = await FirebaseFirestore.instance
            .collectionGroup('messages')
            .where('receiverId', isEqualTo: currentUser)
            .where('senderId', isEqualTo: senderId)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (latestMessageSnapshot.docs.isNotEmpty) {
          // chatteki en son mesajı al
          DocumentSnapshot latestMessageDoc = latestMessageSnapshot.docs.first;
          Map<String, dynamic> data = latestMessageDoc.data() as Map<String, dynamic>;

          String message = data['message'];
          // buraya sender ın fullName ini ekle
          String senderfullName = data['senderfullName'];

          // mesajı ve ismi ekle
          setState(() {
            messages.add(message);
            senderNames.add(senderfullName);
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
          .doc(receiverId) //rDh2hMKWOQ = denizin id si
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