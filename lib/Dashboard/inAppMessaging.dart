import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'dart:core';

class chatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String receiverName;
  final bool isBuyer;

  chatScreen({
    required this.chatId,
    required this.currentUserId,
    required this.receiverName,
    required this.isBuyer
  });

  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen> {

  final TextEditingController _controller = TextEditingController();

  bool isExpanded = false;
  File? _chatImage;
  final picker = ImagePicker();

  // Stream<QuerySnapshot> getMessageStream(String? senderId) {
  //   if (widget.isBuyer) {
  //     return FirebaseFirestore.instance
  //         .collection('buyers')
  //         .doc(senderId)
  //         .collection('chat')
  //         .doc(widget.currentUserId)
  //         .collection('sendMessages')
  //         .orderBy('timestamp', descending: true)
  //         .snapshots();
  //   } else {
  //     return FirebaseFirestore.instance
  //         .collection('sellers')
  //         .doc(senderId)
  //         .collection('chat')
  //         .doc(widget.currentUserId)
  //         .collection('sendMessages')
  //         .orderBy('timestamp', descending: true)
  //         .snapshots();
  //   }
  // }

  Stream<List<DocumentSnapshot>> getCombinedMessageStream(String? senderId) {
    Stream<QuerySnapshot> sendMessagesStream = FirebaseFirestore.instance
        .collection(widget.isBuyer ? 'buyers' : 'sellers')
        .doc(senderId)
        .collection('chat')
        .doc(widget.currentUserId)
        .collection('sendMessages')
        .snapshots();

    Stream<QuerySnapshot> receiveMessagesStream = FirebaseFirestore.instance
        .collection(widget.isBuyer ? 'buyers' : 'sellers')
        .doc(widget.currentUserId)
        .collection('chat')
        .doc(senderId)
        .collection('receiveMessages')
        .snapshots();

    return StreamZip([sendMessagesStream, receiveMessagesStream])
        .map((snapshots) => snapshots.expand((snap) => snap.docs).toList());
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImage = referenceRoot.child('chatImages');
      Reference ref = referenceDirImage.child(imageName);
      // Reference ref = FirebaseStorage.instance.ref().child('post_images/$imageName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> sendMessage(String? senderId, String receiverId, String message) async {

    User? user = FirebaseAuth.instance.currentUser;
    String? senderId = user?.email;

    if (user == null) {
      print('User is not logged in.');
      return;
    }

    String? chatImageUrl = _chatImage != null ? await uploadImage(_chatImage!) : null;

    try{

      DocumentSnapshot buyerSnapshot = await FirebaseFirestore.instance
          .collection('buyers')
          .doc(senderId)
          .get();

      DocumentSnapshot sellerSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(senderId)
          .get();

      print(senderId);
      print(receiverId);

      if (buyerSnapshot.exists) {
        await FirebaseFirestore.instance
            .collection('buyers')
            .doc(senderId)
            .collection('chat')
            .doc(receiverId)
            .collection('sendMessages')
            .add({
          'senderId': senderId,
          'receiverId': receiverId,
          'message': message,
          'chatImage': chatImageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance
            .collection('sellers')
            .doc(receiverId)
            .collection('chat')
            .doc(senderId)
            .collection('receiveMessages')
            .add({
          'senderId': senderId,
          'receiverId': receiverId,
          'message': message,
          'chatImage': chatImageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else if (sellerSnapshot.exists) {
        await FirebaseFirestore.instance
            .collection('sellers')
            .doc(senderId)
            .collection('chat')
            .doc(receiverId)
            .collection('sendMessages')
            .add({
          'senderId': senderId,
          'receiverId': receiverId,
          'message': message,
          'chatImage': chatImageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance
            .collection('buyers')
            .doc(receiverId)
            .collection('chat')
            .doc(senderId)
            .collection('receiveMessages')
            .add({
          'senderId': senderId,
          'receiverId': receiverId,
          'message': message,
          'chatImage': chatImageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        print('Error: senderId does not belong to buyers or sellers collection');
      }
      _controller.clear();
    } catch (e){
      print("Error in sending message: $e");
    }
  }

  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void _selectGalleryImage(String? senderId, String receiverId) async {

    final imagePicker = await picker.pickImage(source: ImageSource.gallery);

    if (imagePicker != null) {
      setState(() {
        _chatImage = File(imagePicker.path);
      });
      sendMessage(senderId, receiverId, "");
    }

  }

  void _selectCameraImage(String? senderId, String receiverId) async {

    final imagePicker = await picker.pickImage(source: ImageSource.camera);

    if (imagePicker != null) {
      setState(() {
        _chatImage = File(imagePicker.path);
      });
      sendMessage(senderId, receiverId, "");
    }
  }

  Future<void> deleteMessage(DocumentSnapshot message) async {
    try {
      String collectionPath = widget.isBuyer ? 'buyers' : 'sellers';

      await FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(message['senderId'])
          .collection('chat')
          .doc(message['receiverId'])
          .collection('sendMessages')
          .doc(message.id)
          .delete();

      await FirebaseFirestore.instance
          .collection(collectionPath == 'buyers' ? 'sellers' : 'buyers')
          .doc(message['receiverId'])
          .collection('chat')
          .doc(message['senderId'])
          .collection('receiveMessages')
          .doc(message.id)
          .delete();

      print("${message} Deleted!");

    } catch (e) {
      print("Error deleting message: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? senderId = user?.email;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.receiverName}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: getCombinedMessageStream(senderId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                // Sort messages by timestamp (ascending order to display from oldest to newest)
                messages.sort((a, b) {
                  Timestamp aTime = a['timestamp'] as Timestamp;
                  Timestamp bTime = b['timestamp'] as Timestamp;
                  return aTime.compareTo(bTime);
                });

                return ListView.builder(
                  reverse: false, // Set to false to show messages from top to bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == senderId; // Check if this message was sent by the current user
                    String imageUrl = message['chatImage'] ?? '';

                    GlobalKey key = GlobalKey();

                    return GestureDetector(
                      key: key,
                      onLongPress: () {
                        RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
                        Offset offset = renderBox.localToGlobal(Offset.zero);
                        showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              offset.dx,
                              offset.dy,
                              offset.dx + renderBox.size.width,
                              offset.dy + renderBox.size.height,
                            ),
                            items: [
                              PopupMenuItem(
                                value: 'Delete',
                                child: Text('Delete'),
                              ),
                              PopupMenuItem(
                                value: 'Forward',
                                child: Text('Forward'),
                              ),
                            ]
                        ).then((value) {
                          if (value == 'Delete') {
                            deleteMessage(message);
                          }
                          if (value == 'Forward') {
                            // Implement forward logic here
                          }
                        });
                      },
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, // Align based on who sent the message
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: imageUrl.isNotEmpty ? Colors.transparent : (isMe ? Colors.blue : Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, // Align text accordingly
                            children: [
                              if (message['message'].isNotEmpty)
                                Text(
                                  message['message'],
                                  style: TextStyle(color: Colors.white),
                                ),
                              if (imageUrl.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          backgroundColor: Colors.black,
                                          child: Container(
                                            height: 700,
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 20,
                                                  right: 20,
                                                  child: IconButton(
                                                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Image.network(
                                      imageUrl,
                                      height: 150,
                                      width: 280,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      prefixIcon: GestureDetector(
                        onTap: toggleExpanded,
                        child: Icon(
                          isExpanded ? Icons.clear : Icons.add,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blueAccent),
                          borderRadius:
                          BorderRadius.circular(20)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(20)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      sendMessage(senderId, widget.currentUserId, message);
                      _controller.clear();
                    } else {
                      print("Cannot send an empty message");
                    }
                  },
                ),
              ],
            ),
          ),
          Visibility(
            visible: isExpanded,
            child: Container(
              height: 80, // Adjust height as needed
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt, size: 30),
                    onPressed: () {
                      _selectCameraImage(
                        senderId,
                        widget.currentUserId,
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.photo_library, size: 30),
                    onPressed: () {
                      _selectGalleryImage(
                        senderId,
                        widget.currentUserId,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
