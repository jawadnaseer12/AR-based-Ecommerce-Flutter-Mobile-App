import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stitchhub_app/Dashboard/Controller/ChatProvider.dart';
import 'package:stitchhub_app/Dashboard/Model/messageModel.dart';

class ChatScreen extends StatelessWidget {
  final String buyerId;
  final String sellerId;
  final String currentUserId;

  ChatScreen({required this.buyerId, required this.sellerId, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView.builder(
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    Message message = chatProvider.messages[index];
                    bool isCurrentUser = message.senderId == currentUserId;
                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: isCurrentUser ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message.content,
                              style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
                            ),
                          ),
                          Text(
                            "${message.timestamp.hour}:${message.timestamp.minute}",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _MessageInputField(buyerId: buyerId, sellerId: sellerId, currentUserId: currentUserId),
        ],
      ),
    );
  }
}

class _MessageInputField extends StatefulWidget {
  final String buyerId;
  final String sellerId;
  final String currentUserId;

  _MessageInputField({required this.buyerId, required this.sellerId, required this.currentUserId});

  @override
  State<_MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<_MessageInputField> {
  TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false).sendMessage(
        widget.buyerId,
        widget.sellerId,
        widget.currentUserId,
        _controller.text,
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: "Enter a message"),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
