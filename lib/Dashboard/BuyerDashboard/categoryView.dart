import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/productListScreen.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/shoppingCart.dart';

class Product {
  final String title;
  final String category;
  final String description;
  final String productSKU;
  final int price;
  final int comparePrice;
  final String storeName;
  final String phoneNum;
  final String email;
  final String imageUrl;
  final String imageURL2;
  final String imageURL3;
  final String imageURL4;

  Product({
    required this.title,
    required this.category,
    required this.description,
    required this.productSKU,
    required this.price,
    required this.comparePrice,
    required this.storeName,
    required this.phoneNum,
    required this.email,
    required this.imageUrl,
    required this.imageURL2,
    required this.imageURL3,
    required this.imageURL4,
  });
}

class categoryScreen extends StatefulWidget {

  final String category;

  const categoryScreen({
    required this.category,
  });

  @override
  State<categoryScreen> createState() => _categoryScreenState();
}

class _categoryScreenState extends State<categoryScreen> {

  int cartCount = 0;
  int selectedQuantity = 1;
  String selectedSize = 'S';

  @override
  void initState() {
    super.initState();
    _fetchCartCount();
  }

  Future<void> _fetchCartCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userCartId = user?.email;

    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('buyers')
        .doc(userCartId)
        .collection('cart')
        .get();

    setState(() {
      cartCount = cartSnapshot.docs.length;
    });
  }

  void addToCart(String title, String category, int saleprice, int compareprice, String description, String productSKU, String storename, String storePhoneNo, String storeEmail, String image1, String image2, String image3, String image4) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userCartId = user?.email;

    FirebaseFirestore.instance.collection('buyers').doc(userCartId).collection('cart').add({
      'product title': title,
      'product category': category,
      'product price': saleprice,
      'discount price': compareprice,
      'product description': description,
      'productSKU': productSKU,
      'store name': storename,
      'store phoneNo': storePhoneNo,
      'store email': storeEmail,
      'quantity': selectedQuantity,
      'product size': selectedSize,
      'imageUrl1': image1,
      'imageUrl2': image2,
      'imageUrl3': image3,
      'imageUrl4': image4,
    });
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.navigate_before),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text('${widget.category}',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500)),
                  ),
                  Spacer(),
                ],
              ),
              actions: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => shoppingCart()),
                          );
                        },
                        icon: SizedBox(
                          height: 25,
                          width: 25,
                          child: Icon(Icons.shopping_cart),
                        ),
                      ),
                    ),
                    if(cartCount >= 0)
                      Positioned(
                        right: 5,
                        top: 0,
                        child: Container(
                          height: 20,
                          width: 20,
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '$cartCount',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            body: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('sellers').snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Unauthorized User'));
                } else if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  var sellers = snapshot.data.docs;
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: sellers.map<Widget>((seller) {

                            String storename = seller['storeName'];
                            String phoneNum = seller['phoneNum'];
                            String email = seller['email'];

                            return FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('sellers')
                                  .doc(seller.id)// Seller ID
                                  .collection('active product')
                                  .where('category', isEqualTo: widget.category)
                                  .get(),
                              builder: (context, AsyncSnapshot productSnapshot) {
                                if (productSnapshot.hasError) {
                                  return Text('Error: ${productSnapshot.error}');
                                } else if (!productSnapshot.hasData) {
                                  return SizedBox();
                                } else {
                                  var products = productSnapshot.data.docs;
                                  return Column(
                                    children: products.map<Widget>((product) {
                                      String title = product['title'];
                                      String category = product['category'];
                                      String description = product['description'];
                                      String productSKU = product['productSKU'];
                                      String imageUrl1 = product['imageUrl1'] ?? '';
                                      String imageUrl2 = product['imageUrl2'] ?? '';
                                      String imageUrl3 = product['imageUrl3'] ?? '';
                                      String imageUrl4 = product['imageUrl4'] ?? '';
                                      int saleprice = int.parse(product['saleCost']);
                                      int compareprice = int.parse(product['compareCost']);

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => productListScreen(
                                              title: title,
                                              category: category,
                                              description: description,
                                              productSKU: productSKU,
                                              saleprice: saleprice,
                                              compareprice: compareprice,
                                              storeName: storename,
                                              phoneNum: phoneNum,
                                              email: email,
                                              imageURL1: imageUrl1,
                                              imageURL2: imageUrl2,
                                              imageURL3: imageUrl3,
                                              imageURL4: imageUrl4,
                                            )),
                                          );
                                        },
                                        child: Container(
                                          height: 140,
                                          margin: EdgeInsets.all(10),
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
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
                                              ),
                                              // SizedBox(width: 5),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                      child: Container(
                                                        width: 180,
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
                                                            text: '$compareprice',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              decoration: TextDecoration.lineThrough,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    RichText(
                                                      text: TextSpan(
                                                        text: 'Category: ',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text: '${widget.category}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 20),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 25,
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.black,
                                                          width: 1.0,
                                                        ),
                                                        color: Colors.transparent,
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          addToCart(
                                                              title,
                                                              category,
                                                              saleprice,
                                                              compareprice,
                                                              description,
                                                              productSKU,
                                                              storename,
                                                              phoneNum,
                                                              email,
                                                              imageUrl1,
                                                              imageUrl2,
                                                              imageUrl3,
                                                              imageUrl4
                                                          );
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            'ADD TO CART',
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
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => productListScreen(
                                                              title: title,
                                                              category: category,
                                                              description: description,
                                                              productSKU: productSKU,
                                                              saleprice: saleprice,
                                                              compareprice: compareprice,
                                                              storeName: storename,
                                                              phoneNum: phoneNum,
                                                              email: email,
                                                              imageURL1: imageUrl1,
                                                              imageURL2: imageUrl2,
                                                              imageURL3: imageUrl3,
                                                              imageURL4: imageUrl4,
                                                            )),
                                                          );
                                                        },
                                                        child: Center(
                                                          child: Text(
                                                            'BUY NOW',
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
                                      );
                                    }).toList(),
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }
              },
            )
        ),
      ),
    );
  }

}
