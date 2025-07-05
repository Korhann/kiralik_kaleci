import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivity.dart';
import 'package:kiralik_kaleci/direct2messagepage.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:rxdart/rxdart.dart';

class SellerDirectMessages extends StatefulWidget {
  const SellerDirectMessages({super.key});

  @override
  State<SellerDirectMessages> createState() => _SellerDirectMessagesState();
}

class _SellerDirectMessagesState extends State<SellerDirectMessages> {
  late String currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!.uid;
  }

  Stream<List<String>> fetchParticipantIds() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final currentUser = user.uid;
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
      (QuerySnapshot sentSnap, QuerySnapshot receivedSnap) {
        Set<String> participantIds = {};
        for (var doc in sentSnap.docs) {
          participantIds.add(doc['receiverId']);
        }
        for (var doc in receivedSnap.docs) {
          participantIds.add(doc['senderId']);
        }
        return participantIds.toList();
      },
    );
  }

  Future<Map<String, dynamic>> fetchConversationData(String participantId) async {
    String lastMessage = await _getLastMessage(participantId);
    String receiverName = await _getReceiverName(participantId);
    String? imageUrl = await _getReceiverImage(participantId);
    int unreadCount = await getUnreadCount(participantId);
    // Optionally, add to SharedPreferences here if needed, but avoid if possible
    return {
      'receiverId': participantId,
      'receiverName': receiverName,
      'lastMessage': lastMessage,
      'imageUrl': imageUrl,
      'unread': unreadCount
    };
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

  Future<void> resetUnredMessages(String participantId) async {
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
      metaDoc.reference.update({'to_msg': 0});
    } else {
      metaDoc.reference.update({'from_msg': 0});
    }
  }

  @override
  Widget build(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final iconSize = width * 0.06;
    return ConnectivityWrapper(
      child: StreamBuilder<List<String>>(
        stream: fetchParticipantIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MessagesShimmer();
          }
          if (!snapshot.hasData){
            return Scaffold(
              body: Container(
                color: sellerbackground,
                child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.message, size: iconSize, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                    'Henüz bir mesajınız bulunmuyor',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white
                    ),
                    textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                  ),
                  ],
                ),
                          ),
              ),
            );
          }
          var participantIds = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: GlobalStyles.textStyle(
                text: 'Mesajlar',
                context: context,
                size: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              backgroundColor: sellerbackground,
              centerTitle: true,
            ),
            backgroundColor: sellerbackground,
            body: ListView.builder(
              itemCount: participantIds.length,
              itemBuilder: (context, index) {
                final participantId = participantIds[index];
                return FutureBuilder<Map<String, dynamic>>(
                  future: fetchConversationData(participantId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return ListTile(
                        title: const SizedBox(),
                      );
                    }
                    var conversation = snapshot.data!;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: conversation['imageUrl'] != null
                            ? NetworkImage(conversation['imageUrl'])
                            : null,
                        child: conversation['imageUrl'] == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(conversation['receiverName'], style: const TextStyle(color: Colors.white)),
                      subtitle: Row(
                        children: [
                          Text(conversation['lastMessage'], style: const TextStyle(color: Colors.white)),
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
                        ],
                      ),
                      onTap: () async {
                        await resetUnredMessages(conversation['receiverId']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Direct2Message(receiverId: conversation['receiverId']),
                          ),
                        );
                      },
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
