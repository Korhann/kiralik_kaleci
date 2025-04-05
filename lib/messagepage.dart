import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/chat_services.dart';
import 'package:kiralik_kaleci/styles/chatBubble.dart';

import 'sharedvalues.dart';


class MessagePage extends StatefulWidget {

  const MessagePage({super.key});
  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {

  final ScrollController _scrollController = ScrollController();

  // sharedvalues dan gelen değerler null 
  String uid = sharedValues.sellerUid;
  bool? istapped = sharedValues.onTapped;

  // dokunulan kullanıcının maili
  String? sellerEmail;

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getEmail(uid);
  }

  void sendMessage() async {
    // sadece mesaj boş değilse gönder
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(sharedValues.sellerUid, _messageController.text);
      // gönderdikten sonra temizle
      _messageController.clear();
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    appBar: AppBar(
      title: Text('$sellerEmail'),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          // Message list section
          Flexible(
            child: _buildMessageList(),
          ),
          // Message input section
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: _buildMessageInput(),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMessageList() {
  return StreamBuilder(
    stream: _chatService.getMessages(sharedValues.sellerUid, _firebaseAuth.currentUser!.uid),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text("Hata ${snapshot.error}");
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text("Yükleniyor");
      }

      // Scroll to the bottom when the message list updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

      return ListView(
        controller: _scrollController,
        children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
      );
    },
  );
}

Widget _buildMessageItem(DocumentSnapshot documentSnapshot) {
  Map<String, dynamic> data = documentSnapshot.data() as Map<String,dynamic>;

  var alignment = (data['uid'] == _firebaseAuth.currentUser!.uid)
    ? Alignment.centerRight
    : Alignment.centerLeft;

  return Container(
    alignment: alignment,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: (data["uid"] == _firebaseAuth.currentUser!.uid) 
        ? CrossAxisAlignment.end 
        : CrossAxisAlignment.start,
        children: [
          // sender email is optional, can be removed
          Text(data['email']),
          const SizedBox(height: 5),
          ChatBubble(message: data['message'])
        ],
      ),
    ),
  );
}

Widget _buildMessageInput() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            obscureText: false,
          ),
        ),
        // send button
        IconButton(
          onPressed: sendMessage,
          icon: const Icon(Icons.arrow_upward),
        ),
      ],
    ),
  );
}
 Future<void> _getEmail(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("Users").doc(uid).get();
      if (snapshot.exists) {
        Map<String,dynamic> data = snapshot.data() as Map<String,dynamic>;
        if (data.isNotEmpty && data.containsKey('email')) {
          setState(() {
            sellerEmail = data['email'] as String;
          });
        }
      } else {
        print("email bulunamadı");
      }
    } catch (e) {
      print("Hata $e");
    }
  }
}