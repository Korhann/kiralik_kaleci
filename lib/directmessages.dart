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
  
  String uid = sharedValues.sellerUid;
  List<String> messages = [];
  List<String> receiverNames = [];
  List<String> distinctReceiverIds = [];
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
          child: Text(
            'Mesajlar',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: receiverNames.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  await _resetUnreadMessages(distinctReceiverIds[index]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Direct2Message(
                        receiverId: distinctReceiverIds[index],
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: FutureBuilder(
                    future: _getReceiverImage(distinctReceiverIds[index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                        return const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.error),
                        );
                      } else {
                        return CircleAvatar(
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
                  trailing: StreamBuilder<int>(
                    stream: _getUnreadMessagesStream(distinctReceiverIds[index]),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data! > 0) {
                        return CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 12,
                          child: Text(
                            '${snapshot.data}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox(); // Show nothing if there are no unread messages
                      }
                    },
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

      messagesSnapshot.docs.forEach((doc) {
        participantIds.add(doc['receiverId'] as String);
      });

      receivedMessagesSnapshot.docs.forEach((doc) {
        participantIds.add(doc['senderId'] as String);
      });

      for (String participantId in participantIds) {
        QuerySnapshot latestMessageSnapshot = await FirebaseFirestore.instance
            .collectionGroup('messages')
            .where('senderId', isEqualTo: currentUser)
            .where('receiverId', isEqualTo: participantId)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (latestMessageSnapshot.docs.isEmpty) {
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

  Stream<int> _getUnreadMessagesStream(String receiverId) {
    try {
      String docPath;

      // Determine the document path
      if (currentUser.compareTo(receiverId) < 0) {
        docPath = '$currentUser\_$receiverId';
      } else {
        docPath = '$receiverId\_$currentUser';
      }

      // Return the stream that listens for changes in the unread message count
      return FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(docPath)
          .collection('messages')
          .doc('messageDoc')
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          if (data['receiverId'] == currentUser) {
            return data['from_msg'] ?? 0;
          } else if (data['senderId'] == currentUser) {
            return data['to_msg'] ?? 0;
          }
        }
        return 0;
      });
    } catch (e) {
      print("Error fetching unread messages stream: $e");
      return Stream.value(0); // Return a stream with 0 unread messages in case of error
    }
  }

  Future<void> _resetUnreadMessages(String receiverId) async {
    try {
      String docPath;

      // Determine the document path
      if (currentUser.compareTo(receiverId) < 0) {
        docPath = '$currentUser\_$receiverId';
      } else {
        docPath = '$receiverId\_$currentUser';
      }

      DocumentReference messageDocRef = FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(docPath)
          .collection('messages')
          .doc('messageDoc');

      DocumentSnapshot messageDocSnapshot = await messageDocRef.get();

      if (messageDocSnapshot.exists && messageDocSnapshot.data() != null) {
        Map<String, dynamic> data = messageDocSnapshot.data() as Map<String, dynamic>;

        if (data['receiverId'] == currentUser) {
          await messageDocRef.update({'from_msg': 0});
        } else if (data['senderId'] == currentUser) {
          await messageDocRef.update({'to_msg': 0});
        }
      }
    } catch (e) {
      print("Error resetting unread messages: $e");
    }
  }
}
