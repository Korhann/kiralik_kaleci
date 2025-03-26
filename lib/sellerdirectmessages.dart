import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivity.dart';
import 'package:kiralik_kaleci/direct2messagepage.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class SellerDirectMessages extends StatefulWidget {
  const SellerDirectMessages({super.key});

  @override
  State<SellerDirectMessages> createState() => _SellerDirectMessagesState();
}

class _SellerDirectMessagesState extends State<SellerDirectMessages> {
  String currentUser = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> conversations = [];

  late Future<void> fetchConvos;

  @override
  void initState() {
    super.initState();
    fetchConvos = _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    try {
      QuerySnapshot sentMessages = await FirebaseFirestore.instance
          .collectionGroup('messages')
          .where('senderId', isEqualTo: currentUser)
          .get();

      QuerySnapshot receivedMessages = await FirebaseFirestore.instance
          .collectionGroup('messages')
          .where('receiverId', isEqualTo: currentUser)
          .get();

      Set<String> participantIds = {};

      for (var doc in sentMessages.docs) {
        participantIds.add(doc['receiverId']);
      }

      for (var doc in receivedMessages.docs) {
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

      setState(() {
        conversations = tempConversations;
      });
    } catch (e) {
      print("Error fetching conversations: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: FutureBuilder(
        future: fetchConvos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MessagesShimmer();
          }
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
            subtitle: Text(conversation['lastMessage'],style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Direct2Message(receiverId: conversation['receiverId']),
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
