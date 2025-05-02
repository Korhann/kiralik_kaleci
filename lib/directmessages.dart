import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivity.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:rxdart/rxdart.dart';
import 'direct2messagepage.dart';

class DirectMessages extends StatefulWidget {
  const DirectMessages({super.key});

  @override
  State<DirectMessages> createState() => _DirectMessagesState();
}

class _DirectMessagesState extends State<DirectMessages> {

  String currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
  }

  Stream<List<Map<String, dynamic>>> fetchConversations() {
  Stream<QuerySnapshot> sentStream = FirebaseFirestore.instance
      .collectionGroup('messages')
      .where('senderId', isEqualTo: currentUser)
      .snapshots();

  Stream<QuerySnapshot> receivedStream = FirebaseFirestore.instance
      .collectionGroup('messages')
      .where('receiverId', isEqualTo: currentUser)
      .snapshots();

  return Rx.combineLatest2(
    sentStream,
    receivedStream,
    (QuerySnapshot sentSnap, QuerySnapshot receivedSnap) async {  
      Set<String> participantIds = {};

      for (var doc in sentSnap.docs) {
        participantIds.add(doc['receiverId']);
      }

      for (var doc in receivedSnap.docs) {
        participantIds.add(doc['senderId']);
      }

      List<Map<String, dynamic>> tempConversations = [];

      for (String participantId in participantIds) {
        String lastMessage = await _getLastMessage(participantId);
        String receiverName = await _getReceiverName(participantId);
        String? imageUrl = await _getReceiverImage(participantId);

        tempConversations.add({
          'receiverId': participantId,
          'receiverName': receiverName,
          'lastMessage': lastMessage,
          'imageUrl': imageUrl,
        });
      }
      return tempConversations;
    },
  ).asyncMap((futureList) => futureList);
}


  Future<String> _getLastMessage(String receiverId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('senderId', whereIn: [currentUser, receiverId])
        .where('receiverId', whereIn: [currentUser, receiverId])
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['lastMessage'];
    }
    return "";
  }

  Future<String> _getReceiverName(String userId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (snapshot.exists) {
      return snapshot['fullName'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  Future<String?> _getReceiverImage(String userId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (snapshot.exists && snapshot['sellerDetails']?['imageUrls'] != null) {
      List<dynamic> images = snapshot['sellerDetails']['imageUrls'];
      return images.isNotEmpty ? images.first : null;
    }
    return null;
  }

//   Future<void> _resetUnreadMessages(String receiverId) async {
//     try {
//       String docPath;

//       // Determine the document path
//       if (currentUser.compareTo(receiverId) < 0) {
//         docPath = '${currentUser}_$receiverId';
//       } else {
//         docPath = '${receiverId}_$currentUser';
//       }

//       DocumentReference messageDocRef = FirebaseFirestore.instance
//           .collection('chat_rooms')
//           .doc(docPath)
//           .collection('messages')
//           .doc('messageDoc');

//       DocumentSnapshot messageDocSnapshot = await messageDocRef.get();

//       if (messageDocSnapshot.exists && messageDocSnapshot.data() != null) {
//         Map<String, dynamic> data = messageDocSnapshot.data() as Map<String, dynamic>;

//         if (data['receiverId'] == currentUser) {
//           await messageDocRef.update({'from_msg': 0});
//         } else if (data['senderId'] == currentUser) {
//           await messageDocRef.update({'to_msg': 0});
//         }
//       }
//     } catch (e) {
//       print("Error resetting unread messages: $e");
//     }
//   }

    //todo: Bunu kullanmana gerek yok zaten sayfa değiştirince yenileniyor
//   Future<String> _getUpdatedName(String userId) async {
//   try {
//     DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

//     if (userSnapshot.exists) {
//       Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
//       return userData['fullName'] ?? 'Unknown';
//     } else {
//       return 'Unknown';
//     }
//   } catch (e) {
//     print("Error fetching user name: $e");
//     return 'Unknown';
//   }
// }

  @override
Widget build(BuildContext context) {
  return ConnectivityWrapper(
    child: StreamBuilder<List<Map<String, dynamic>>>(
      stream: fetchConversations(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MessagesShimmer();
        }

        var conversations = snapshot.data!;
        print('conversation $conversations');

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                'Mesajlar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ),
            backgroundColor: background,
            centerTitle: true,
          ),
          backgroundColor: background,
          body: ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              var conversation = conversations[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: conversation['imageUrl'] != null
                      ? NetworkImage(conversation['imageUrl'])
                      : null,
                  child: conversation['imageUrl'] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(conversation['receiverName']),
                subtitle: Text(conversation['lastMessage']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Direct2Message(receiverId: conversation['receiverId']),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    ),
  );
}
}



