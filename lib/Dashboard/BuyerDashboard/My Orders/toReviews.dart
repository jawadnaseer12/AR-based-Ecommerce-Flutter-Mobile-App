import 'dart:math';
import 'package:stitchhub_app/Dashboard/inAppMessaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class productReview extends StatefulWidget {
  const productReview({super.key});

  @override
  State<productReview> createState() => _productReviewState();
}

class _productReviewState extends State<productReview> {

  final TextEditingController _reviewController = TextEditingController();
  bool isExpanded = false;
  String productReview = '';

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
                child: Text('My Review',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500)),
              ),
              TextButton(
                  onPressed: () {
                    
                  },
                  child: Text('clear')),
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
                        String productSKU = order['productSKU'];
                        String consigneeName = order['consignee name'];
                        String imageUrl = order['imageURL'] ?? '';
                        String orderNo = order['order number'] ?? '';
                        int totalBill = order['total bill'] ?? 5500;
                        int itemQuantity = order['quantity'] ?? 1;
                        String status = 'Delivered';
                        var timestamp = order['dateTime'] as Timestamp;
                        var date = timestamp.toDate();
                        var dateTime = DateFormat.yMMMMd().format(date);
                        String orderId = order.id;

                        return reviewCard(
                            title: title,
                            userID: userId,
                            productSKU: productSKU,
                            consigneeName: consigneeName,
                            imageUrl: imageUrl,
                            orderNo: orderNo,
                            status: status,
                            orderId: orderId,
                            totalBill: totalBill,
                            itemQuantity: itemQuantity,
                            dateTime: dateTime,
                        );
                      }).toList() ?? [],
                    ),
                  );
                } else {
                  return Center(
                    child: Text('No Review Order'),
                  );
                }
              }
            }
        ),
      ),
    );
  }
}

class reviewCard extends StatefulWidget {
  final String title;
  final String? userID;
  final String productSKU;
  final String consigneeName;
  final String imageUrl;
  final String orderNo;
  final String status;
  final String orderId;
  final int totalBill;
  final int itemQuantity;
  final String dateTime;

  reviewCard({
    required this.title,
    required this.userID,
    required this.productSKU,
    required this.consigneeName,
    required this.imageUrl,
    required this.orderNo,
    required this.status,
    required this.orderId,
    required this.totalBill,
    required this.itemQuantity,
    required this.dateTime,
  });

  @override
  State<reviewCard> createState() => _reviewCardState();
}

class _reviewCardState extends State<reviewCard> {

  final TextEditingController _reviewController = TextEditingController();
  bool isExpanded = false;
  String productReview = '';
  bool isReviewSubmitted = false;
  String submittedReview = '';

  @override
  void initState() {
    super.initState();
    _checkReview();
  }

  void _checkReview() async {
    try {
      var reviewSnapshot = await FirebaseFirestore.instance
          .collection('buyers')
          .doc(widget.userID)
          .collection('product review')
          .where('orderId', isEqualTo: widget.orderNo)
          .get();

      if (reviewSnapshot.docs.isNotEmpty) {
        var reviewData = reviewSnapshot.docs.first.data();
        setState(() {
          isReviewSubmitted = true;
          submittedReview = reviewData['review'];
          // customerName = reviewData['customer name'];
        });
      }
    } catch (e) {
      print('Error checking review: $e');
    }
  }

  Future<void> _addReview(String review, String title, String productSku, String consigneeName, String orderID) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email;

    if (userEmail == null) return;

    QuerySnapshot sellerSnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .get();

    for (var sellerDoc in sellerSnapshot.docs) {
      QuerySnapshot activeProductSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerDoc.id)
          .collection('active product')
          .where('productSKU', isEqualTo: widget.productSKU)
          .get();

      if (activeProductSnapshot.docs.isNotEmpty) {
        // Add the review to the 'product_review' subcollection
        await FirebaseFirestore.instance
            .collection('sellers')
            .doc(sellerDoc.id)
            .collection('active product')
            .doc(activeProductSnapshot.docs.first.id)
            .collection('product review')
            .doc(orderID)
            .set({
          'review': review,
          'reviewerId': userEmail,
          'product title': title,
          'consignee name': consigneeName,
          'orderId': orderID,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance
            .collection('buyers')
            .doc(userEmail)
            .collection('product review')
            .doc(orderID)
            .set({
          'review': review,
          'reviewerId': userEmail,
          'product title': title,
          'consignee name': consigneeName,
          'orderId': orderID,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review added successfully!')),
        );
        return;
      }
    }
    // Navigator.of(context).pop(); // Close the progress dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product not found!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isExpanded ? 290 : 205,
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
              Text('Order No: ${widget.orderNo}'),
              Text('${widget.dateTime}'),
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
                              Text('RS ${widget.totalBill}', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              Text('${widget.itemQuantity}', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          child: widget.imageUrl != null
                              ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                              : Icon(Icons.add),
                        ),
                        SizedBox(width: 10),
                        Container(
                          width: 300,
                          child: Text('${widget.title}',
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
                width: 250,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${widget.status}'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 5),
              IconButton(
                onPressed: () {

                },
                icon: Icon(Icons.insert_comment_rounded),
              ),
              SizedBox(width: 5),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.expand_more, color: Colors.white, size: 14),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
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
                    child: Text('Return'),
                    value: 'return',
                  ),
                ],
                onSelected: (String value) {
                  if (value == 'print') {

                  } else if (value == 'view') {

                  } else if (value == 'return') {

                  }
                },
              ),
            ],
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: isReviewSubmitted
                  ? Container(
                      child: Row(
                        children: [
                          Container(
                            width: 360,
                            child: Text('${submittedReview}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        labelText: 'Add Review',
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blueAccent),
                            borderRadius:
                            BorderRadius.circular(20)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5)),
                            borderRadius:
                            BorderRadius.circular(20)),
                      ),
                      onChanged: (value) {
                        setState(() {
                          productReview = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
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
                      _addReview(productReview, widget.title, widget.productSKU, widget.consigneeName, widget.orderNo);
                    },
                    child: Text("Submit"),
                  ),
                ],
              )
            ),
          // SizedBox(height: 5),
        ],
      ),
    );
  }
}

