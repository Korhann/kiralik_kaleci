import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/sharedvalues.dart';

import 'message.dart';

class ChatService extends ChangeNotifier{
  // get instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // kullanıcı ismini atmak için
  Map<String,dynamic> ?receiverFullName;
  late String receiverFullNames;
  // firstore daki ilk resmi al
  late String receiverImage;
  // gönderen kişinin ismini al
  late String senderfullName;

  String chatRoomId = '';

  Future<void> initializeIds(String userId, String otherUserId) async {
    // MESAJ GÖNDERİLDİMİ GÖNDERİLMEDİMİ DİYE BAKMADAN HEMEN EKLİYOR !!
    List<String> ids = [userId, otherUserId];
    ids.sort();
    chatRoomId = ids.join('_');
    // listeye gönderiyor, hot restart yapınca listedeki veriler siliniyor !! (mantıklı değil direct message için farklı query oluştur)
    if (chatRoomId.isNotEmpty && !sharedValues.idsroom.contains(chatRoomId)) {
      sharedValues.idsroom.add(chatRoomId);
    } 
    print("ids room is ${sharedValues.idsroom}");
  }

  // send message
  Future<void> sendMessage(String receiverId, String message) async {
    
    await initializeIds(_firebaseAuth.currentUser!.uid, receiverId);

    // current kullanıcı bilgilerini al
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    await _getReceiverDetails(receiverId);
    await _getSenderfullName(currentUserId);

    // receiver mail inide ekle ve receiver ismini ve soyadını
    Message newMessage = Message(
      senderId: currentUserId, 
      senderEmail: currentUserEmail, 
      receiverId: receiverId, 
      message: message, 
      receiverfullName: receiverFullNames,
      senderfullName: senderfullName,
      receiverImage: receiverImage,
      timeStamp: timestamp
      );


    // yeni mesaj ekle
    await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId,otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore.collection('chat_rooms')
    .doc(chatRoomId)
    .collection('messages')
    .orderBy('timestamp',descending: false)
    .snapshots();
  }

  Future<void> _getReceiverDetails(receiverId) async{

    DocumentSnapshot snapshot = await _firestore.collection("Users").doc(receiverId).get();
    // firestore verilerini al
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    // kullanıcıdan fullName al
    if (data.isNotEmpty && data.containsKey('fullName')) {
      receiverFullNames = data['fullName'];
    }

    // kullanıcıdan resimleri almak için
    if (data.isNotEmpty && data.containsKey('sellerDetails')) {
      Map<String,dynamic> sellerDetails = data['sellerDetails'];
      if (sellerDetails.isNotEmpty && sellerDetails.containsKey("imageUrls")) {
        List<dynamic> imageUrls = sellerDetails['imageUrls'];
        // firestore'a yüklenen resim
        receiverImage = imageUrls.first;
      }
    }
  }
  Future<void> _getSenderfullName(currentuserId) async{
    DocumentSnapshot snapshot = await _firestore.collection("Users").doc(currentuserId).get();
    Map<String, dynamic> data = snapshot.data() as Map<String,dynamic>;

    if (data.isNotEmpty && data.containsKey('fullName')) {
      senderfullName = data['fullName'];
    }

  }
}