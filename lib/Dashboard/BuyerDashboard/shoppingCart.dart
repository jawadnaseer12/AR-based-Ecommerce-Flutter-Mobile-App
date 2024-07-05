import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/productListScreen.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/checkoutProcess.dart';

class shoppingCart extends StatefulWidget {
  const shoppingCart({super.key});

  @override
  State<shoppingCart> createState() => _shoppingCartState();
}

class _shoppingCartState extends State<shoppingCart> {

  bool isSelectAll = false;
  Map<String, bool> selectedItems = {};

  void deleteSelectedItems(String userId) {
    FirebaseFirestore.instance
        .collection('buyers')
        .doc(userId)
        .collection('cart')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        var cartItem = document.data();
        var isChecked = cartItem['isChecked'] ?? false;
        if (isChecked) {
          FirebaseFirestore.instance.collection('buyers')
              .doc(userId)
              .collection('cart')
              .doc(document.id)
              .delete();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.email;

    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
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
                  child: Text('My Cart',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500)),
                ),
                TextButton(
                    onPressed: () {
                      deleteSelectedItems(userId!);
                    },
                    child: Text('Delete')),
              ],
            ),
          ),
          body: Column(
            children:  [
              CheckboxListTile(
                title: Text('Select All'),
                value: isSelectAll,
                onChanged: (bool? value) {
                  setState(() {
                    isSelectAll = value ?? false;
                    for (var key in selectedItems.keys) {
                      selectedItems[key] = isSelectAll;
                    }
                  });
                },
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('buyers')
                      .doc(userId)
                      .collection('cart')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('Your cart is empty.'));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var cartItem = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                          var title = cartItem['product title'];
                          var saleprice = cartItem['product price'];
                          var discount = cartItem['discount price'];
                          var description = cartItem['product description'] ?? '';
                          var storename = cartItem['store name'] ?? '';
                          var storePhoneNo = cartItem['store phoneNo'] ?? '';
                          var storeEmail = cartItem['store email'] ?? '';
                          var productSize = cartItem['product size'] ?? '';
                          String imageUrl1 = cartItem['imageUrl1'] ?? '';
                          String imageUrl2 = cartItem['imageUrl2'] ?? '';
                          String imageUrl3 = cartItem['imageUrl3'] ?? '';
                          String imageUrl4 = cartItem['imageUrl4'] ?? '';
                          int quantity = cartItem['quantity'];
                          var isChecked = cartItem['isChecked'] ?? false;

                          return Column(
                            children: [
                              Container(
                                height: 140,
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Checkbox(
                                      value: isChecked,
                                      onChanged: (newValue) {
                                        FirebaseFirestore.instance.collection('buyers')
                                            .doc(userId)
                                            .collection('cart')
                                            .doc(snapshot.data!.docs[index].id)
                                            .update({'isChecked': newValue});
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        border: Border.all(color: Colors.black.withOpacity(0.3)),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: imageUrl1 != null
                                          ? Image.network(imageUrl1, fit: BoxFit.cover)
                                          : DecoratedBox(decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('assets/product1.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                      // decoration: BoxDecoration(
                                      //   image: DecorationImage(
                                      //     image: AssetImage('assets/product1.jpg'),
                                      //     fit: BoxFit.cover,
                                      //   ),
                                      // ),
                                    ),
                                    // SizedBox(width: 5),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15, left: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              width: 150,
                                              child: Text('${title}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text('Quantity: ${quantity}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 5),
                                          RichText(
                                            text: TextSpan(
                                              text: '\R\s\. ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: '$saleprice  ',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '$discount',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    decoration: TextDecoration.lineThrough,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Container(
                                    //   height: 22,
                                    //   width: 22,
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.grey,
                                    //     borderRadius: BorderRadius.circular(0),
                                    //   ),
                                    //   child: GestureDetector(
                                    //     onTap: () {
                                    //       setState(() {
                                    //         if (quantity > 1) {
                                    //           quantity--;
                                    //         }
                                    //       });
                                    //     },
                                    //     child: Icon(Icons.remove, size: 20, color: Colors.white),
                                    //   ),
                                    // ),
                                    // Container(
                                    //   height: 22,
                                    //   width: 22,
                                    //   decoration: BoxDecoration(
                                    //     border: Border.all(color: Colors.grey),
                                    //     borderRadius: BorderRadius.circular(0),
                                    //   ),
                                    //   child: Center(
                                    //     child: Text(quantity.toString(),
                                    //       style: TextStyle(
                                    //           fontSize: 12,
                                    //           color: Colors.black,
                                    //           fontWeight: FontWeight.bold),
                                    //     ),
                                    //   ),
                                    // ),
                                    // Container(
                                    //   height: 22,
                                    //   width: 22,
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.grey,
                                    //     borderRadius: BorderRadius.circular(0),
                                    //   ),
                                    //   child: GestureDetector(
                                    //     onTap: () {
                                    //       setState(() {
                                    //         quantity++;
                                    //       });
                                    //     },
                                    //     child: Icon(Icons.add, size: 20, color: Colors.white),
                                    //   ),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 25,
                                            width: 70,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 1.0,
                                              ),
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => productListScreen(
                                                    title: title,
                                                    description: description,
                                                    saleprice: saleprice,
                                                    compareprice: discount,
                                                    storeName: storename,
                                                    phoneNum: storePhoneNo,
                                                    email: storeEmail,
                                                    imageURL1: imageUrl1,
                                                    imageURL2: imageUrl2,
                                                    imageURL3: imageUrl3,
                                                    imageURL4: imageUrl4,
                                                  )),
                                                );
                                              },
                                              child: Center(
                                                child: Text(
                                                  'VIEW',
                                                  style: TextStyle(
                                                    fontSize: 7,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            height: 25,
                                            width: 70,
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => checkoutProcess(
                                                    title: title,
                                                    saleprice: saleprice,
                                                    compareprice: discount,
                                                    storeName: storename,
                                                    email: storeEmail,
                                                    quantity: quantity,
                                                    productSize: productSize,
                                                    imageURL1: imageUrl1,
                                                  )),
                                                );
                                              },
                                              child: Center(
                                                child: Text(
                                                  'PROCEED',
                                                  style: TextStyle(
                                                    fontSize: 7,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}
