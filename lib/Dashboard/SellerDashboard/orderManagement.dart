import 'dart:math';
import 'package:stitchhub_app/Dashboard/inAppMessaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class orderManagement extends StatefulWidget {
  const orderManagement({super.key});
  // final int selectedTabIndex;
  //
  // const orderManagement({Key? key, required this.selectedTabIndex}) : super(key: key);
  @override
  State<orderManagement> createState() => _orderManagementState();
}

class _orderManagementState extends State<orderManagement> {

  String newChatID = '';

  String generateChatId() {
    Random random = Random();
    String chatID = '';
    for (int i = 0; i < 7; i++) {
      chatID += random.nextInt(10).toString();
    }
    return chatID;
  }

  String getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception("No user is currently logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.email;
    final String currentUserId = getCurrentUserId();
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight + 50),
            child: AppBar(
              leading: IconButton(onPressed: () {Navigator.of(context).pop();}, icon: Icon(Icons.navigate_before)),
              title: Center(child: Text('Order Manager', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
              centerTitle: true,
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Pending'),
                  Tab(text: 'Shipped'),
                  Tab(text: 'Delivered'),
                  Tab(text: 'Return'),
                ],
                isScrollable: true,
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 5, top: 7),
                  // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: tCardByColor),
                  child: IconButton(
                    onPressed: () {},
                    icon: SizedBox(
                      height: 20,
                      width: 20,
                      child: Icon(Icons.search, color: Color(0xff485fb3)),
                    ),
                  ),
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Container(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('sellers')
                        .doc(userId)
                        .collection('order')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        var orders = snapshot.data?.docs;
                        if (orders != null && orders.isNotEmpty) {
                          return SingleChildScrollView(
                            child: Column(
                              children: orders?.map((order) {
                                String title = order['product title'];
                                String productSKU = order['productSKU'];
                                String consigneeName = order['consignee name'];
                                String consigneeId = order['consignee email'];
                                String imageUrl = order['imageURL'] ?? '';
                                String orderNo = order['order number'] ?? '';
                                int totalBill = order['total bill'] ?? 5500;
                                int itemQuantity = order['quantity'] ?? 1;
                                String status = 'Pending';
                                var timestamp = order['dateTime'] as Timestamp;
                                var date = timestamp.toDate();
                                var dateTime = DateFormat.yMMMMd().format(date);
                                String orderId = order.id;

                                return Container(
                                  height: 240,
                                  width: double.infinity,
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Order No: $orderNo'),
                                          Text('$dateTime'),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Container(
                                          height: 110,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                                              top: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(height: 5),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: 130,
                                                      height: 50,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('Total Bill: '),
                                                          Text('RS ${totalBill}', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 150,
                                                      height: 50,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('Total Item: '),
                                                          Text('$itemQuantity', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        border: Border.all(color: Colors.black.withOpacity(0.3)),
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: imageUrl != null
                                                          ? Image.network(imageUrl, fit: BoxFit.cover)
                                                          : Icon(Icons.add),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Container(
                                                      width: 300,
                                                      child: Text('$title',
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 280,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                                              ),
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) => Center(
                                                      child: Container(
                                                        height: 80,
                                                        width: 120,
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(0.3),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ));
                                                shippedOrder(userId, orderId, consigneeId);
                                              },
                                              child: Center(
                                                child: Container(
                                                  height: 30,
                                                  width: 260,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.4),
                                                    borderRadius: BorderRadius.circular(5),
                                                    // border: Border(right: BorderSide(width: 4)),
                                                  ),
                                                  child: Center(child: Text('Ready to Ship',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          IconButton(
                                              onPressed: () {

                                                newChatID = generateChatId();
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            chatScreen(
                                                                chatId: newChatID,
                                                                currentUserId: consigneeId,
                                                                receiverName: consigneeName,
                                                                isBuyer: false,
                                                            )));

                                              },
                                              icon: Icon(Icons.insert_comment_rounded),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: Icon(Icons.more_horiz),
                                            // iconSize: 25,
                                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                              PopupMenuItem(
                                                child: Text('Print'),
                                                value: 'print',
                                              ),
                                              PopupMenuItem(
                                                child: Text('View'),
                                                value: 'view',
                                              ),
                                              PopupMenuItem(
                                                child: Text('Cancel'),
                                                value: 'cancel',
                                              ),
                                            ],
                                            onSelected: (String value) {
                                              if (value == 'print') {

                                              } else if (value == 'view') {

                                              } else if (value == 'cancel') {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) => Center(
                                                      child: Container(
                                                        height: 80,
                                                        width: 120,
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(0.3),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ));
                                                cancelOrder(userId, orderId, consigneeId);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('$status'),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList() ?? [],
                            ),
                          );
                        } else {
                          return Center(
                            child: Text('No Pending Order'),
                          );
                        }
                      }
                    }
                ),
              ),
              Container(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('sellers')
                        .doc(userId)
                        .collection('shipped order')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        var orders = snapshot.data?.docs;
                        if (orders != null && orders.isNotEmpty) {
                          return SingleChildScrollView(
                            child: Column(
                              children: orders?.map((order) {
                                String title = order['product title'];
                                String productSKU = order['productSKU'];
                                String consigneeName = order['consignee name'];
                                String consigneeId = order['consignee email'];
                                String imageUrl = order['imageURL'] ?? '';
                                String orderNo = order['order number'] ?? '';
                                int totalBill = order['total bill'] ?? 5500;
                                int itemQuantity = order['quantity'] ?? 1;
                                String status = 'Shipped';
                                var timestamp = order['dateTime'] as Timestamp;
                                var date = timestamp.toDate();
                                var dateTime = DateFormat.yMMMMd().format(date);
                                String orderId = order.id;

                                return Container(
                                  height: 240,
                                  width: double.infinity,
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Order No: $orderNo'),
                                          Text('$dateTime'),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Container(
                                          height: 110,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                                              top: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(height: 5),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: 130,
                                                      height: 50,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('Total Bill: '),
                                                          Text('RS ${totalBill}', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 150,
                                                      height: 50,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('Total Item: '),
                                                          Text('$itemQuantity', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        border: Border.all(color: Colors.black.withOpacity(0.3)),
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: imageUrl != null
                                                          ? Image.network(imageUrl, fit: BoxFit.cover)
                                                          : Icon(Icons.add),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Container(
                                                      width: 300,
                                                      child: Text('$title',
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 280,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                                              ),
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) => Center(
                                                      child: Container(
                                                        height: 80,
                                                        width: 120,
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(0.3),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ));
                                                deliveredOrder(userId, orderId, consigneeId);
                                              },
                                              child: Center(
                                                child: Container(
                                                  height: 30,
                                                  width: 260,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.4),
                                                    borderRadius: BorderRadius.circular(5),
                                                    // border: Border(right: BorderSide(width: 4)),
                                                  ),
                                                  child: Center(child: Text('Mark Delivered',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          IconButton(
                                            onPressed: () {

                                              newChatID = generateChatId();
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          chatScreen(
                                                              chatId: newChatID,
                                                              currentUserId: consigneeId,
                                                              receiverName: consigneeName,
                                                            isBuyer: false,
                                                          )));

                                            },
                                            icon: Icon(Icons.insert_comment_rounded),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: Icon(Icons.more_horiz),
                                            // iconSize: 25,
                                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                              PopupMenuItem(
                                                child: Text('Print'),
                                                value: 'print',
                                              ),
                                              PopupMenuItem(
                                                child: Text('View'),
                                                value: 'view',
                                              ),
                                              PopupMenuItem(
                                                child: Text('Cancel'),
                                                value: 'cancel',
                                              ),
                                            ],
                                            onSelected: (String value) {
                                              if (value == 'print') {

                                              } else if (value == 'view') {

                                              } else if (value == 'cancel') {

                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('$status'),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList() ?? [],
                            ),
                          );
                        } else {
                          return Center(
                            child: Text('No Shipped Order'),
                          );
                        }
                      }
                    }
                ),
              ),
              Container(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('sellers')
                        .doc(userId)
                        .collection('deliver order')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        var orders = snapshot.data?.docs;
                        if (orders != null && orders.isNotEmpty) {
                          return SingleChildScrollView(
                            child: Column(
                              children: orders?.map((order) {
                                String title = order['product title'];
                                String productSKU = order['productSKU'];
                                String consigneeName = order['consignee name'];
                                String consigneeId = order['consignee email'];
                                String imageUrl = order['imageURL'] ?? '';
                                String orderNo = order['order number'] ?? '';
                                int totalBill = order['total bill'] ?? 5500;
                                int itemQuantity = order['quantity'] ?? 1;
                                String status = 'Delivered';
                                var timestamp = order['dateTime'] as Timestamp;
                                var date = timestamp.toDate();
                                var dateTime = DateFormat.yMMMMd().format(date);
                                String orderId = order.id;

                                return Container(
                                  height: 205,
                                  width: double.infinity,
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Order No: $orderNo'),
                                          Text('$dateTime'),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Container(
                                          height: 110,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                                              top: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(height: 5),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: 130,
                                                      height: 50,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('Total Bill: '),
                                                          Text('RS ${totalBill}', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 150,
                                                      height: 50,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('Total Item: '),
                                                          Text('$itemQuantity', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        border: Border.all(color: Colors.black.withOpacity(0.3)),
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: imageUrl != null
                                                          ? Image.network(imageUrl, fit: BoxFit.cover)
                                                          : Icon(Icons.add),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Container(
                                                      width: 300,
                                                      child: Text('$title',
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 280,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                Text('$status'),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          IconButton(
                                            onPressed: () {

                                              newChatID = generateChatId();
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          chatScreen(
                                                            chatId: newChatID,
                                                            currentUserId: consigneeId,
                                                            receiverName: consigneeName,
                                                            isBuyer: false,
                                                          )));

                                            },
                                            icon: Icon(Icons.insert_comment_rounded),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: Icon(Icons.more_horiz),
                                            // iconSize: 25,
                                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                              PopupMenuItem(
                                                child: Text('Print'),
                                                value: 'print',
                                              ),
                                              PopupMenuItem(
                                                child: Text('View'),
                                                value: 'view',
                                              ),
                                              PopupMenuItem(
                                                child: Text('Cancel'),
                                                value: 'cancel',
                                              ),
                                            ],
                                            onSelected: (String value) {
                                              if (value == 'print') {

                                              } else if (value == 'view') {

                                              } else if (value == 'cancel') {

                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList() ?? [],
                            ),
                          );
                        } else {
                          return Center(
                            child: Text('No Delivered Order'),
                          );
                        }
                      }
                    }
                ),
              ),
              Container(
                child: Center(
                  child: Text('No Return Orders'),
                ),
              ),
            ],
          ),
        ),
    );
  }
}

Future<void> shippedOrder(String? userId, String orderId, String consigneeId) async {
  try {
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(userId)
        .collection('order')
        .doc(orderId)
        .get();

    DocumentSnapshot buyerOrderSnapshot = await FirebaseFirestore.instance
        .collection('buyers')
        .doc(consigneeId)
        .collection('order')
        .doc(orderId)
        .get();

    if (orderSnapshot.exists && buyerOrderSnapshot.exists) {
      var orderData = orderSnapshot.data() as Map<String, dynamic>?;
      var buyerOrderData = buyerOrderSnapshot.data() as Map<String, dynamic>?;

      if (orderData != null && buyerOrderData != null) {
        await FirebaseFirestore.instance
            .collection('sellers')
            .doc(userId)
            .collection('shipped order')
            .doc(orderId)
            .set(orderData);

        await FirebaseFirestore.instance
            .collection('buyers')
            .doc(consigneeId)
            .collection('shipped order')
            .doc(orderId)
            .set(buyerOrderData);

        await FirebaseFirestore.instance
            .collection('sellers')
            .doc(userId)
            .collection('order')
            .doc(orderId)
            .delete();

        await FirebaseFirestore.instance
            .collection('buyers')
            .doc(consigneeId)
            .collection('order')
            .doc(orderId)
            .delete();

        print('Order moved to Shipped and deleted from Pending collection.');
      } else {
        print('Order data or Buyer order data is null.');
      }
    } else {
      print('Order or Buyer order does not exist.');
    }
  } catch (e) {
    print('Error moving product to Shipped collection: $e');
  }
}


Future<void> deliveredOrder(String? userId, String orderId, String consigneeId) async {

  try{
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(userId)
        .collection('shipped order')
        .doc(orderId)
        .get();

    DocumentSnapshot buyerOrderSnapshot = await FirebaseFirestore.instance
        .collection('buyers')
        .doc(consigneeId)
        .collection('shipped order')
        .doc(orderId)
        .get();

    if (orderSnapshot.exists || buyerOrderSnapshot.exists) {

      var orderData = orderSnapshot.data() as Map<String, dynamic>;
      var buyerOrderData = buyerOrderSnapshot.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('deliver order')
          .doc(orderId)
          .set(orderData);

      await FirebaseFirestore.instance
          .collection('buyers')
          .doc(consigneeId)
          .collection('deliver order')
          .doc(orderId)
          .set(buyerOrderData);

      FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('shipped order')
          .doc(orderId)
          .delete();

      FirebaseFirestore.instance
          .collection('buyers')
          .doc(consigneeId)
          .collection('shipped order')
          .doc(orderId)
          .delete();

      print('Order moved to Delivered and deleted from Shipped collection.');
    }
  } catch (e) {
    print('Error moving product to Delivered collection: $e');
  }

}

Future<void> cancelOrder(String? userId, String orderId, String consigneeId) async {

  try{
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(userId)
        .collection('order')
        .doc(orderId)
        .get();

    DocumentSnapshot buyerOrderSnapshot = await FirebaseFirestore.instance
        .collection('buyers')
        .doc(consigneeId)
        .collection('order')
        .doc(orderId)
        .get();

    if (orderSnapshot.exists || buyerOrderSnapshot.exists) {

      var orderData = orderSnapshot.data() as Map<String, dynamic>;
      var buyerOrderData = buyerOrderSnapshot.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('cancel order')
          .doc(orderId)
          .set(orderData);

      await FirebaseFirestore.instance
          .collection('buyers')
          .doc(consigneeId)
          .collection('cancel order')
          .doc(orderId)
          .set(buyerOrderData);

      FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('order')
          .doc(orderId)
          .delete();

      FirebaseFirestore.instance
          .collection('buyers')
          .doc(consigneeId)
          .collection('order')
          .doc(orderId)
          .delete();

      print('Order moved to Shipped and deleted from Pending collection.');
    }
  } catch (e) {
    print('Error moving product to Shipped collection: $e');
  }

}
