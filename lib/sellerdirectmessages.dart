import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivity.dart';
import 'package:kiralik_kaleci/direct2messagepage.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:rxdart/rxdart.dart';

class SellerDirectMessages extends StatefulWidget {
  const SellerDirectMessages({super.key});

  @override
  State<SellerDirectMessages> createState() => _SellerDirectMessagesState();
}

class _SellerDirectMessagesState extends State<SellerDirectMessages> {
  String currentUser = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> conversations = [];


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
        int unreadCount = await getUnreadCount(participantId);

        tempConversations.add({
          'receiverId': participantId,
          'receiverName': receiverName,
          'lastMessage': lastMessage,
          'imageUrl': imageUrl,
          'unread': unreadCount
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

  Future<int> getUnreadCount(String participantId) async {
  List<String> ids = [currentUser, participantId];
  ids.sort();
  String chatRoomId = ids.join('_');

  DocumentSnapshot metaDoc = await FirebaseFirestore.instance
    .collection('chat_rooms')
    .doc(chatRoomId)
    .collection('messages')
    .doc('meta')
    .get();

  if (!metaDoc.exists) return 0;

  Map<String, dynamic> data = metaDoc.data() as Map<String, dynamic>;

  if (data['senderId'] == currentUser) {
    return data['to_msg'] ?? 0;
  } else {
    return data['from_msg'] ?? 0;
  }
} 
  
  Future<void> resetUnredMessages(String participantId) async{
    List<String> ids = [currentUser, participantId];
    ids.sort();
    String chatRoomId = ids.join('_');

    DocumentSnapshot metaDoc = await FirebaseFirestore.instance
    .collection('chat_rooms')
    .doc(chatRoomId)
    .collection('messages')
    .doc('meta')
    .get();
    
    Map<String, dynamic> data = metaDoc.data() as Map<String, dynamic>;
    if (data['senderId'] == currentUser) {
      metaDoc.reference.update({
        'to_msg': 0
      });
    } else {
      metaDoc.reference.update({
        'from_msg': 0
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: StreamBuilder(
        stream: fetchConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MessagesShimmer();
          }
          var conversations = snapshot.data!;
          return Scaffold(
          appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Mesajlar', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white)),
        backgroundColor: sellerbackground,
        centerTitle: true,
      ),
      backgroundColor: sellerbackground,
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          var conversation = conversations[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: conversation['imageUrl'] != null ? NetworkImage(conversation['imageUrl']) : null,
              child: conversation['imageUrl'] == null ? const Icon(Icons.person) : null,
            ),
            title: Text(conversation['receiverName'], style: TextStyle(color: Colors.white)),
            subtitle: Row(
                  children: [
                    Text(conversation['lastMessage'], style: TextStyle(color: Colors.white)),
                    const Spacer(),
                    if (conversation['unread'] > 0) 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${conversation['unread']}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                  ]
                ),
            onTap: () async{
              await resetUnredMessages(conversation['receiverId']);
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => Direct2Message(receiverId: conversation['receiverId']),
                ),
              );
            },
          );
        },
      ),
    );
        }
      ),
    );
  }
}
