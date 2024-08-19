import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/messageContent.dart';
import 'package:kiralik_kaleci/sharedvalues.dart';

import 'message.dart';

class ChatService extends ChangeNotifier{

  // TODO: bence unreadmessages fonksiyonu mesajı göndermeden önce çalışaması lazım(yarın yine bak) CHATGPT den dün sormuştun ona bak !!!
  
  late String currentUserId;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String,dynamic> ?receiverFullName;
  late String receiverFullNames;
  late String receiverImage;
  late String senderfullName;
  int fromMsg = 0;
  int toMsg = 0;
  late Message newMessage;
  String chatRoomId = '';

  Future<void> initializeIds(String userId, String otherUserId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    chatRoomId = ids.join('_');
    if (chatRoomId.isNotEmpty && !sharedValues.idsroom.contains(chatRoomId)) {
      sharedValues.idsroom.add(chatRoomId);
    } 
  }

  Future<void> sendMessage(String receiverId, String message) async {
  await initializeIds(_firebaseAuth.currentUser!.uid, receiverId);

  currentUserId = _firebaseAuth.currentUser!.uid;
  final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
  final Timestamp timestamp = Timestamp.now();

  await _getReceiverDetails(receiverId);
  await _getSenderfullName(currentUserId);

  DocumentReference messageDocRef = _firestore
    .collection('chat_rooms')
    .doc(chatRoomId)
    .collection('messages')
    .doc('messageDoc'); 

  DocumentSnapshot messageDocSnapshot = await messageDocRef.get();

  // Retrieve the last message
  String lastMessage = '';
  if (messageDocSnapshot.exists) {
    final messageListSnapshot = await messageDocRef.collection('messageList')
        .orderBy('addtime', descending: true)
        .limit(1)
        .get();
        
    if (messageListSnapshot.docs.isNotEmpty) {
      lastMessage = messageListSnapshot.docs.first.get('message') as String;
    }
  }

  // yoksa yeniden yarat
  if (!messageDocSnapshot.exists) {
    Message newMessage = Message(
      senderId: currentUserId, 
      senderEmail: currentUserEmail, 
      receiverId: receiverId, 
      lastmessage: message, // Set the initial message
      receiverfullName: receiverFullNames,
      senderfullName: senderfullName,
      receiverImage: receiverImage,
      timeStamp: timestamp,
      fromMsg: fromMsg,
      toMsg: toMsg
    );
    await messageDocRef.set(newMessage.toMap());
  } else {
    // eğer varsa güncelle
    await messageDocRef.update({
      'lastMessage': message,
      'timeStamp': timestamp
    });
  }

  // messageList koleksiyonuna ekliyor
  MessageContent messageContent = MessageContent(
    addtime: timestamp, 
    message: message, 
    uid: currentUserId,
    email: currentUserEmail
  );

  // messageList e ekleniyor burada
  Future<DocumentReference<Map<String, dynamic>>> documentReference = messageDocRef.collection('messageList').add(messageContent.toMap());
  // todo: bunu mesajı göndermeden önce göndermem lazım
  await unredMessages(documentReference, receiverId,messageDocRef);
  
}


  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore.collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .doc('messageDoc')
      .collection('messageList')
      .orderBy('addtime', descending: false)
      .snapshots();
  }

  Future<void> _getReceiverDetails(receiverId) async {
    DocumentSnapshot snapshot = await _firestore.collection("Users").doc(receiverId).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    if (data.isNotEmpty && data.containsKey('fullName')) {
      receiverFullNames = data['fullName'];
    }

    if (data.isNotEmpty && data.containsKey('sellerDetails')) {
      Map<String,dynamic> sellerDetails = data['sellerDetails'];
      if (sellerDetails.isNotEmpty && sellerDetails.containsKey("imageUrls")) {
        List<dynamic> imageUrls = sellerDetails['imageUrls'];
        receiverImage = imageUrls.first;
      }
    }
  }

  Future<void> _getSenderfullName(currentuserId) async {
    DocumentSnapshot snapshot = await _firestore.collection("Users").doc(currentuserId).get();
    Map<String, dynamic> data = snapshot.data() as Map<String,dynamic>;

    if (data.isNotEmpty && data.containsKey('fullName')) {
      senderfullName = data['fullName'];
    }
  }

  Future<void> unredMessages(Future<DocumentReference<Map<String,dynamic>>> documentReference, String receiverID, DocumentReference messageDocRef) async {

    DocumentReference<Map<String, dynamic>> messageListdoc = await documentReference;
    // buradan messageList teki uid yi alıyorum
    DocumentSnapshot<Map<String, dynamic>> messageListsnapshot = await messageListdoc.get();
    // buradan messageDoc daki senderId ve receiverId yi alıyorum
    DocumentSnapshot messageDocSnapshot = await messageDocRef.get();

    if(messageDocSnapshot.exists && messageDocSnapshot.data() != null) {
      Map<String, dynamic>? messageData = messageDocSnapshot.data() as Map<String, dynamic>;

      fromMsg = messageData.containsKey('from_msg') ? messageData['from_msg'] : 0;
      toMsg = messageData.containsKey('to_msg') ? messageData['to_msg'] : 0;

    if (messageListsnapshot.data()!['uid'] == messageData['senderId']) {
      fromMsg = fromMsg + 1;
    } else if (messageListsnapshot.data()!['uid'] == messageData['receiverId']) {
      toMsg = toMsg + 1;
    }
  }
    // burada fromMsg ve toMsg i update ediyor
    await messageDocRef.update({
      'from_msg': fromMsg,
      'to_msg': toMsg
    });
  }
}
