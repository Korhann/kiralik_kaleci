import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final String receiverfullName;
  final String receiverImage;
  final Timestamp timeStamp;
  final String senderfullName;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.receiverfullName,
    required this.receiverImage,
    required this.senderfullName,
    required this.timeStamp
  });

  Map<String, dynamic> toMap(){
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'receiverfullName': receiverfullName,
      'senderfullName':senderfullName,
      'receiverImage': receiverImage,
      'timestamp': timeStamp,
    };
  }
}
