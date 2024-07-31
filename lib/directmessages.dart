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

// todo: Başkasının gönderdiği mesajlar sen mesaj göndermeden gelmiyo !!

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
    appBar: AppBar(
      backgroundColor: background,
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mesajlar',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black
              ),
            )
          ],
        ),
      )
    ),
    body: ListView.builder(
      itemCount: receiverNames.length,
      itemBuilder: (BuildContext context, int index) {
        // burası yapılacak
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
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
                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
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
                trailing: IconButton(onPressed: () {
                  _deleteChat(distinctReceiverIds[index]);
                }, icon: const Icon(Icons.delete, color: Colors.red,)),
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

    // Fetch messages where the current user is either sender or receiver
    QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('senderId', isEqualTo: currentUser)
        .where('deletedBySender', isEqualTo: false)
        .get();

    QuerySnapshot receivedMessagesSnapshot = await FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('receiverId', isEqualTo: currentUser)
        .where('deletedByReceiver', isEqualTo: false)
        .get();

    Set<String> participantIds = {};

    // Add sender and receiver IDs to a set to ensure uniqueness
    messagesSnapshot.docs.forEach((doc) {
      participantIds.add(doc['receiverId'] as String);
    });

    receivedMessagesSnapshot.docs.forEach((doc) {
      participantIds.add(doc['senderId'] as String);
    });

    for (String participantId in participantIds) {
      // eğer current user gönderen ise
      QuerySnapshot latestMessageSnapshot = await FirebaseFirestore.instance
          .collectionGroup('messages')
          .where('senderId', isEqualTo: currentUser)
          .where('receiverId', isEqualTo: participantId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (latestMessageSnapshot.docs.isEmpty) {
        // current user a gönderilmiş ise
        latestMessageSnapshot = await FirebaseFirestore.instance
            .collectionGroup('messages')
            .where('senderId', isEqualTo: participantId)
            .where('receiverId', isEqualTo: currentUser)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
      }

      if (latestMessageSnapshot.docs.isNotEmpty) {
        DocumentSnapshot latestMessageDoc = latestMessageSnapshot.docs.first;
        Map<String, dynamic> data = latestMessageDoc.data() as Map<String, dynamic>;

        String message = data['lastMessage'];
        String receiverName = currentUser == data['senderId'] ? data['receiverfullName'] : data['senderfullName'];

        setState(() {
          messages.add(message);
          receiverNames.add(receiverName);
          distinctReceiverIds.add(participantId);
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

  Future<void> _deleteChat(String receiverId) async {
    // mesajı sadece gönderen silebiliyor
    try {
      QuerySnapshot chatMessages = await FirebaseFirestore.instance
          .collectionGroup('messages')
          .where('senderId', isEqualTo: currentUser)
          .where('receiverId', isEqualTo: receiverId)
          .get();

      for (DocumentSnapshot doc in chatMessages.docs) {
        await doc.reference.update({'deletedBySender': true});
      }

      setState(() {
        int index = distinctReceiverIds.indexOf(receiverId);
        distinctReceiverIds.removeAt(index);
        receiverNames.removeAt(index);
        messages.removeAt(index);
      });

    } catch (e) {
      print("Error deleting chat: $e");
    }
  }
}
