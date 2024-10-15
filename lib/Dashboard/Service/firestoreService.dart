import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stitchhub_app/Dashboard/Model/messageModel.dart';


class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<Message>> getMessages(String buyerId, String sellerId) {
    return firestore
        .collection('buyers')
        .doc(buyerId)
        .collection('chat')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }

  Future<void> sendMessage(String buyerId, String sellerId, Message message) async {
    WriteBatch batch = firestore.batch();

    DocumentReference buyerChatRef = firestore
        .collection('buyers')
        .doc(buyerId)
        .collection('chat')
        .doc();

    DocumentReference sellerChatRef = firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('chat')
        .doc();

    batch.set(buyerChatRef, message.toMap());
    batch.set(sellerChatRef, message.toMap());

    await batch.commit();
  }
}
