import 'dart:math';
import 'package:stitchhub_app/Dashboard/inAppMessaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class orderReceive extends StatefulWidget {
  const orderReceive({super.key});

  @override
  State<orderReceive> createState() => _orderReceiveState();
}

class _orderReceiveState extends State<orderReceive> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.email;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.navigate_before),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text('Receive Orders',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500)),
              ),
              TextButton(
                  onPressed: () {

                  },
                  child: Text('Clear')),
            ],
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('buyers')
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
                                          child: Center(child: Text('Submit Return',
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
                                    ],
                                    onSelected: (String value) {
                                      if (value == 'print') {

                                      } else if (value == 'view') {

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
                    child: Text('No Delivered Order'),
                  );
                }
              }
            }
        ),
      ),
    );
  }
}
