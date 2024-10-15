import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String content;
  final DateTime timestamp;

  Message({required this.senderId, required this.content, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
