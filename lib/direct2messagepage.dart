import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/chat_services.dart';
import 'package:kiralik_kaleci/styles/chatBubble.dart';

class Direct2Message extends StatefulWidget {
  final String receiverId;
  const Direct2Message({super.key, required this.receiverId});

  @override
  State<Direct2Message> createState() => _Direct2MessageState();
}

class _Direct2MessageState extends State<Direct2Message> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? sellerEmail;

  @override
  void initState() {
    super.initState();
    _getEmail(widget.receiverId);
    _chatService.initializeIds(_firebaseAuth.currentUser!.uid, widget.receiverId);
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverId, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true, 
    appBar: AppBar(
      title: Text(sellerEmail ?? 'Loading...'),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: Column(
      children: [
        // Messages List
        Expanded(
          child: _buildMessageList(),
        ),
        
        // Message Input Field
        _buildMessageInput(),
        const SizedBox(height: 20)
      ],
    ),
  );
}



  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverId, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot documentSnapshot) {
    // bunun document i yanlış olduğu için göstermiyor
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    var alignment = (data['uid'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: (data['uid'] == _firebaseAuth.currentUser!.uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              data['email'] ?? '',
              style: GoogleFonts.inter(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            ChatBubble(message: data['message']),
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
            child: Focus(
              child: TextField(
                autofocus: true,
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Mesaj yazın',
                  border: OutlineInputBorder(),
                ),
                obscureText: false,
              ),
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Future<void> _getEmail(String receiverId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("Users").doc(receiverId).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('email')) {
          setState(() {
            sellerEmail = data['email'] as String;
          });
        }
      } else {
        print("Email not found");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
}
