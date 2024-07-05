import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// class Product {
//   final String title;
//   final String category;
//   final String description;
//   final double salePrice;
//   final double comparePrice;
//   final String status;
//
//   Product({
//     required this.title,
//     required this.category,
//     required this.description,
//     required this.salePrice,
//     required this.comparePrice,
//     required this.status,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'category': category,
//       'description': description,
//       'salePrice': salePrice,
//       'comparePrice': comparePrice,
//       'status': status,
//     };
//   }
// }

class productManagement extends StatefulWidget {
  const productManagement({super.key});

  @override
  State<productManagement> createState() => _productManagementState();
}

class _productManagementState extends State<productManagement> {

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.email;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 50),
          child: AppBar(
            leading: IconButton(onPressed: () {Navigator.of(context).pop();}, icon: Icon(Icons.navigate_before)),
            title: Center(child: Text('Product Manager', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Draft'),
                Tab(text: 'Active'),
                Tab(text: 'Deactive'),
                Tab(text: 'Deleted'),
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
                      .collection('draft product')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      var products = snapshot.data?.docs;
                      if (products != null && products.isNotEmpty) {
                        return SingleChildScrollView(
                          child: Column(
                            children: products?.map((product) {
                              String title = product['title'];
                              String imageUrl = product['imageUrl1'] ?? '';
                              // double draftsaleprice = double.parse(product['saleCost']);
                              // double draftcompareprice = double.parse(product['compareCost']);
                              String productId = product.id;

                              int? draftsaleprice;
                              int? draftcompareprice;

                              if (product['saleCost'] != null) {
                                try {
                                  draftsaleprice = int.parse(product['saleCost']);
                                } catch (e) {
                                  print('Error parsing saleCost: $e');
                                  draftsaleprice = null;
                                }
                              }

                              if (product['compareCost'] != null) {
                                try {
                                  draftcompareprice = int.parse(product['compareCost']);
                                } catch (e) {
                                  print('Error parsing compareCost: $e');
                                  draftcompareprice = null;
                                }
                              }

                              return Container(
                                height: 120,
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(8),
                                          width: 70,
                                          height: 70,
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
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  width: 200,
                                                  child: Text(title,
                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
                                                      text: '${draftsaleprice?.toStringAsFixed(2) ?? 'N/A'}  ',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: '${draftcompareprice?.toStringAsFixed(2) ?? 'N/A'}',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        decoration: TextDecoration.lineThrough,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Text('Sale Price: \R\s ${draftsaleprice?.toStringAsFixed(2) ?? 'N/A'}'),
                                              // Text('Compare Price: \R\s ${draftcompareprice?.toStringAsFixed(2) ?? 'N/A'}'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert),
                                      iconSize: 25,
                                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                        PopupMenuItem(
                                          child: Text('Edit'),
                                          value: 'edit',
                                        ),
                                        PopupMenuItem(
                                          child: Text('View'),
                                          value: 'view',
                                        ),
                                        PopupMenuItem(
                                          child: Text('Delete'),
                                          value: 'delete',
                                        ),
                                      ],
                                      onSelected: (String value) {
                                        if (value == 'edit') {

                                        } else if (value == 'view') {

                                        } else if (value == 'delete') {
                                          deleteDraftProduct(userId, productId);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList() ?? [],
                          ),
                        );
                      } else {
                        return Center(
                              child: Text('No Draft List'),
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
                    .collection('active product')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var products = snapshot.data?.docs;
                    if (products != null && products.isNotEmpty) {
                      return SingleChildScrollView(
                        child: Column(
                          children: products.map((product) {
                            String title = product['title'];
                            String imageUrl = product['imageUrl1'] ?? '';
                            int activesaleprice = int.parse(product['saleCost']);
                            int activecompareprice = int.parse(product['compareCost']);
                            // int productStock = int.parse(product['stock']);
                            String productId = product.id;

                            return Container(
                              height: 120,
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(8),
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          border: Border.all(color: Colors.black.withOpacity(0.3)),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: imageUrl != null
                                            ? Image.network(imageUrl, fit: BoxFit.cover)
                                            : Icon(Icons.add),
                                      ),
                                      SizedBox(width: 5),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Container(
                                                width: 200,
                                                child: Text(title,
                                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
                                                    text: '${activesaleprice}  ',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: '${activecompareprice}',
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
                                                text: 'Stock: ',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: '0',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert),
                                    iconSize: 25,
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                      PopupMenuItem(
                                        child: Text('Edit'),
                                        value: 'edit',
                                      ),
                                      PopupMenuItem(
                                        child: Text('View'),
                                        value: 'view',
                                      ),
                                      PopupMenuItem(
                                        child: Text('Deactivate'),
                                        value: 'deactivate',
                                      ),
                                      PopupMenuItem(
                                        child: Text('Delete'),
                                        value: 'delete',
                                      ),
                                    ],
                                    onSelected: (String value) {
                                      if (value == 'edit') {

                                      } else if (value == 'view') {

                                      } else if (value == 'deactivate') {
                                        deActiveProduct(userId, productId);
                                      } else if (value == 'delete') {

                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList() ?? [],
                        ),
                      );
                    } else {
                      return Center(
                        child: Text('No Active List'),
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
                      .collection('deActive product')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      var products = snapshot.data!.docs;
                      if (products != null && products.isNotEmpty) {
                        return SingleChildScrollView(
                          child: Column(
                              children: products.map((product) {
                                String title = product['title'] ?? '';
                                String imageUrl = product['imageUrl1'] ?? '';
                                int activesaleprice = int.parse(product['saleCost']);
                                int activecompareprice = int.parse(product['compareCost']);
                                // int productStock = int.parse(product['stock']);
                                String productId = product.id;

                                return Container(
                                  height: 120,
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(8),
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              border: Border.all(color: Colors.black.withOpacity(0.3)),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: imageUrl.isNotEmpty
                                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                                : Icon(Icons.add),
                                          ),
                                          SizedBox(width: 5),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    width: 200,
                                                    child: Text(title,
                                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
                                                        text: '${activesaleprice}  ',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: '${activecompareprice}',
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
                                                    text: 'Stock: ',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: '0',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert),
                                        iconSize: 25,
                                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                          PopupMenuItem(
                                            child: Text('Edit'),
                                            value: 'edit',
                                          ),
                                          PopupMenuItem(
                                            child: Text('View'),
                                            value: 'view',
                                          ),
                                          PopupMenuItem(
                                            child: Text('Reactivate'),
                                            value: 'reactivate',
                                          ),
                                          PopupMenuItem(
                                            child: Text('Delete Permanently'),
                                            value: 'delete_permanently',
                                          ),
                                        ],
                                        onSelected: (String value) {
                                          if (value == 'edit') {

                                          } else if (value == 'view') {

                                          } else if (value == 'reactivate') {

                                          } else if (value == 'delete_permanently') {

                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ),
                        );
                      } else {
                        return Center(
                          child: Text('No Deactive List'),
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
                      .collection('delete product')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      var products = snapshot.data!.docs;
                      if (products != null && products.isNotEmpty) {
                        return SingleChildScrollView(
                          child: Column(
                            children: products.map((product) {
                              String title = product['title'] ?? '';
                              String imageUrl = product['imageUrl1'] ?? '';
                              int activesaleprice = int.parse(product['saleCost']);
                              int activecompareprice = int.parse(product['compareCost']);
                              // int productStock = int.parse(product['stock']);
                              String productId = product.id;

                              return Container(
                                height: 120,
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(8),
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            border: Border.all(color: Colors.black.withOpacity(0.3)),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: imageUrl.isNotEmpty
                                              ? Image.network(imageUrl, fit: BoxFit.cover)
                                              : Icon(Icons.add),
                                        ),
                                        SizedBox(width: 5),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  width: 200,
                                                  child: Text(title,
                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
                                                      text: '${activesaleprice}  ',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: '${activecompareprice}',
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
                                                  text: 'Stock: ',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: '0',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert),
                                      iconSize: 25,
                                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                        PopupMenuItem(
                                          child: Text('View'),
                                          value: 'view',
                                        ),
                                        PopupMenuItem(
                                          child: Text('Restore'),
                                          value: 'restore',
                                        ),
                                      ],
                                      onSelected: (String value) {
                                        if (value == 'view') {

                                        } else if (value == 'restore') {

                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      } else {
                        return Center(
                          child: Text('No Deleted List'),
                        );
                      }
                    }
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> deActiveProduct(String? userId, String productId) async {

  try{
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(userId)
        .collection('active product')
        .doc(productId)
        .get();

    if (productSnapshot.exists) {

      var productData = productSnapshot.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('deActive product')
          .doc(productId)
          .set(productData);

      FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('active product')
          .doc(productId)
          .delete();

      print('Product moved to deActive product collection and deleted from active product collection.');
    }
  } catch (e) {
    print('Error moving product to deActive product collection: $e');
  }
}

Future<void> deleteDraftProduct(String? userId, String productId) async {
  try{
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(userId)
        .collection('draft product')
        .doc(productId)
        .get();

    if (productSnapshot.exists) {

      var productData = productSnapshot.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('delete product')
          .doc(productId)
          .set(productData);

      FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('draft product')
          .doc(productId)
          .delete();

      print('Product moved to delete product collection and deleted from draft product collection.');
    }
  } catch (e) {
    print('Error moving product to delete product collection: $e');
  }
}
