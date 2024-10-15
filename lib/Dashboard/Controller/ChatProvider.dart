import 'package:flutter/foundation.dart';
import 'package:stitchhub_app/Dashboard/Model/messageModel.dart';
import 'package:stitchhub_app/Dashboard/Service/firestoreService.dart';


class ChatProvider with ChangeNotifier {
  final FirestoreService firestoreService = FirestoreService();
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  void loadMessages(String buyerId, String sellerId) {
    firestoreService.getMessages(buyerId, sellerId).listen((messages) {
      _messages = messages;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String buyerId, String sellerId, String senderId, String content) async {
    Message message = Message(
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
    );

    await firestoreService.sendMessage(buyerId, sellerId, message);
  }
}
