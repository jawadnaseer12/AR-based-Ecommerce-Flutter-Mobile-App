import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/productDetail.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/orderDetail.dart';
import 'package:stitchhub_app/Dashboard/changeProfile.dart';
import 'dart:io';
import 'package:stitchhub_app/Dashboard/imagePicker.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/addProduct.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/orderManagement.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/productManagement.dart';
import 'package:stitchhub_app/UserAuthentication/homePage.dart';
import 'package:stitchhub_app/UserAuthentication/login.dart';

class sellerDashboard extends StatefulWidget {
  const sellerDashboard({super.key});

  @override
  State<sellerDashboard> createState() => _sellerDashboardState();
}

class _sellerDashboardState extends State<sellerDashboard> {
  TextEditingController searchController = TextEditingController();

  int _selectedIndex = 0;

  // Stream<Map<String, int>> getProductCountsStream(String sellerId) {
  //   return FirebaseFirestore.instance
  //       .collection('sellers')
  //       .doc(sellerId)
  //       .snapshots()
  //       .map((snapshot) {
  //     final data = snapshot.data();
  //     if (data == null) return {};
  //     return {
  //       'drafts': data['drafts'] ?? 0,
  //       'active': data['active'] ?? 0,
  //       'deactive': data['deactive'] ?? 0,
  //       'rejected': data['rejected'] ?? 0,
  //     };
  //   });
  // }

  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    Dashboard(),
    Inbox(),
    Notification(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;
    // if (user == null) {
    //   return Text('User not logged in');
    // }
    // final sellerId = user.uid;
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.black, // Change the color of the selected item
              unselectedItemColor: Colors.black,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  // backgroundColor: Colors.white,
                  icon: Icon(Icons.home, color: Colors.black),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  // backgroundColor: Colors.white,
                  icon: Icon(Icons.dashboard, color: Colors.black),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  // backgroundColor: Colors.white,
                  icon: Icon(Icons.mail, color: Colors.black),
                  label: 'Inbox',
                ),
                BottomNavigationBarItem(
                  // backgroundColor: Colors.white,
                  icon: Icon(Icons.notification_important_rounded, color: Colors.black),
                  label: 'Notification',
                ),
                BottomNavigationBarItem(
                  // backgroundColor: Colors.white,
                  icon: Icon(Icons.person, color: Colors.black),
                  label: 'Profile',
                ),
              ]),
        ),
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  // final Stream<Map<String, int>> productCountsStream;
  //
  // Dashboard({required this.productCountsStream});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  late String _storeName = '';
  late String _username = '';


  Uint8List? _storeImage;

  final ProductManagement _productManagement = ProductManagement();
  int _activeProductCount = 0;
  int _draftProductCount = 0;
  int _deActiveProductCount = 0;
  int _deleteProductCount = 0;

  final OrderManagement _orderManagement = OrderManagement();
  int _pendingOrderCount = 0;
  int _acceptOrderCount = 0;
  int _completeOrderCount = 0;
  int _returnOrderCount = 0;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);

    try {
      if(img != null) {
        setState(() {
          _storeImage = img;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image Successfully Uploaded!'),
            ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select an image file.'),
            ));
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image.'),
          ));
    }
  }

  // File? _storeImageFile;
  // final ImagePicker _imagePicker = ImagePicker();
  //
  // Future<void> _selectImage() async {
  //
  //   try{
  //     final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
  //     if (pickedFile != null) {
  //       final File imageFile = File(pickedFile.path);
  //       final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
  //       if (decodedImage != null) {
  //         setState(() {
  //           _storeImageFile = imageFile;
  //         });
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Please select an image file.'),
  //             ));
  //       }
  //     }
  //   } catch (e) {
  //     print('Error picking image: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error picking image.'),
  //         ));
  //   }
  //
  //   // final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
  //   // if (pickedFile != null) {
  //   //   setState(() {
  //   //     _storeImageFile = File(pickedFile.path);
  //   //   });
  //   // }
  // }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchActiveProductCount();
    _fetchDraftProductCount();
    _deActiveDraftProductCount();
    _fetchDeleteProductCount();
    _fetchPendingOrderCount();
    _fetchShippedOrderCount();
    _fetchDeliveredOrderCount();
    _fetchReturnOrderCount();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('sellers').doc(email).get();

      setState(() {
        _storeName = userData['storeName'];
        _username = userData['userame'];
      });
    }
  }

  Future<void> _fetchActiveProductCount() async {
    int count = await _productManagement.getActiveProductCountForCurrentUser();

    setState(() {
      _activeProductCount = count;
    });

  }
  Future<void> _fetchDraftProductCount() async {
    int count = await _productManagement.getDraftProductCountForCurrentUser();

    setState(() {
      _draftProductCount = count;
    });

  }
  Future<void> _deActiveDraftProductCount() async {
    int count = await _productManagement.getDeActiveProductCountForCurrentUser();

    setState(() {
      _deActiveProductCount = count;
    });

  }
  Future<void> _fetchDeleteProductCount() async {
    int count = await _productManagement.getDeleteProductCountForCurrentUser();

    setState(() {
      _deleteProductCount = count;
    });

  }

  Future<void> _fetchPendingOrderCount() async {
    int count = await _orderManagement.getPendingOrderCountForCurrentUser();

    setState(() {
      _pendingOrderCount = count;
    });
  }
  Future<void> _fetchShippedOrderCount() async {
    int count = await _orderManagement.getShippedOrderCountForCurrentUser();

    setState(() {
      _acceptOrderCount = count;
    });
  }
  Future<void> _fetchDeliveredOrderCount() async {
    int count = await _orderManagement.getDeliveredOrderCountForCurrentUser();

    setState(() {
      _completeOrderCount = count;
    });
  }
  Future<void> _fetchReturnOrderCount() async {
    int count = await _orderManagement.getReturnOrderCountForCurrentUser();

    setState(() {
      _returnOrderCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            // leading: Icon(Icons.menu, color: Colors.black, size: 30),
            title: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Stitch',
                          style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontSize: 22,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: 'HUB.',
                          style: TextStyle(
                              fontFamily: 'Ubuntu',
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 10),
                // Padding(
                //     padding: EdgeInsets.only(left: 15),
                //     child: Icon(Icons.shopping_cart)),
              ],
            ),
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          Stack(
                            children: [
                              _storeImage != null ?
                              CircleAvatar(
                                radius: 35,
                                backgroundImage: MemoryImage(_storeImage!),
                              )
                                  : CircleAvatar(
                                radius: 35,
                                backgroundImage: NetworkImage('https://as2.ftcdn.net/v2/jpg/05/49/98/39/1000_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'),
                              ),
                              Positioned(
                                child: IconButton(
                                  onPressed: () {
                                    selectImage();
                                  },
                                  icon: Icon(Icons.add_a_photo, size: 20),
                                ),
                                bottom: -12,
                                left: 34,
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                const EdgeInsets.only(left: 11, top: 7),
                                child: Text('${_storeName}',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Row(
                                  children: [
                                    Text(
                                        'www.stitchhub.pk/shop/${_username}',
                                        style: TextStyle(fontSize: 10)),
                                    Icon(Icons.navigate_next),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: IconButton(
                                onPressed: () {

                                },
                                icon: Icon(Icons.share_outlined),
                                iconSize: 10,
                                color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
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
                    child: Icon(Icons.notifications, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          // backgroundColor: Color(0XFFDBE3EB),
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: 380,
                    decoration: BoxDecoration(
                      // color: Colors.black,
                      // borderRadius: BorderRadius.circular(5),
                      border: Border(bottom: BorderSide(width: 1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text('Order Management',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => orderManagement()),
                                );
                              },
                              icon: Icon(Icons.navigate_next),
                              color: Colors.black,
                              iconSize: 20,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 60,
                                width: 80,
                                decoration: BoxDecoration(
                                  // color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border(right: BorderSide(width: 4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 2),
                                    Text('${_pendingOrderCount}', style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black)),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => orderManagement()),
                                        );
                                      },
                                      child: Text('Pending',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.white,
                                          )),
                                    ),
                                    // Text('10', style: TextStyle(fontSize: 10)),
                                    // IconButton(
                                    //     onPressed: () {},
                                    //     icon: Icon(Icons.navigate_next),
                                    //     iconSize: 13,
                                    //     color: Colors.white,
                                    // ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 60,
                                width: 80,
                                decoration: BoxDecoration(
                                  // color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border(right: BorderSide(width: 4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 2),
                                    Text('${_acceptOrderCount}', style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black)),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => orderManagement()),
                                        );
                                      },
                                      child: Text('To Ship',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.white,
                                          )),
                                    ),
                                    // Text('10', style: TextStyle(fontSize: 10)),
                                    // IconButton(
                                    //     onPressed: () {},
                                    //     icon: Icon(Icons.navigate_next),
                                    //     iconSize: 13,
                                    //     color: Colors.white,
                                    // ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 60,
                                width: 80,
                                decoration: BoxDecoration(
                                  // color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border(right: BorderSide(width: 4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 2),
                                    Text('${_completeOrderCount}', style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black)),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => orderManagement()),
                                        );
                                      },
                                      child: Text('Deliver',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.white,
                                          )),
                                    ),
                                    // Text('10', style: TextStyle(fontSize: 10)),
                                    // IconButton(
                                    //     onPressed: () {},
                                    //     icon: Icon(Icons.navigate_next),
                                    //     iconSize: 13,
                                    //     color: Colors.white,
                                    // ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 60,
                                width: 80,
                                decoration: BoxDecoration(
                                  // color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border(right: BorderSide(width: 4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 2),
                                    Text('${_returnOrderCount}', style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black)),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => orderManagement()),
                                        );
                                      },
                                      child: Text('Return',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.white,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 200,
                    width: 380,
                    decoration: BoxDecoration(
                      // color: Colors.black,
                      // borderRadius: BorderRadius.circular(5),
                      border: Border(bottom: BorderSide(width: 1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text('Product Management',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => productManagement()),
                                );
                              },
                              icon: Icon(Icons.navigate_next),
                              color: Colors.black,
                              iconSize: 20,
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Container(
                          height: 50,
                          width: 350,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(5),
                            // border: Border(right: BorderSide(width: 4)),
                          ),
                          child: Center(
                            child: TextButton(
                              child: Text(
                                'Add Product',
                                style: TextStyle(
                                    fontSize: 15,
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => addProduct()),
                                );
                              },
                            ),
                            // SizedBox(height: 20),
                            // ProductCount(),
                          ),
                        ),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 60,
                                width: 80,
                                decoration: BoxDecoration(
                                  // color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border(right: BorderSide(width: 4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // StreamBuilder<Map<String, int>>(
                                    //     stream: widget.productCountsStream,
                                    //     builder: (context, snapshot) {
                                    //       if (snapshot.connectionState == ConnectionState.waiting) {
                                    //         return Center(child: CircularProgressIndicator());
                                    //       }
                                    //       if (snapshot.hasError) {
                                    //         return Text('Error: ${snapshot.error}'); // Return an empty container
                                    //       }
                                    //       final counts = snapshot.data ?? {};
                                    //       return Column(
                                    //         children: [
                                    //           SizedBox(height: 2),
                                    //           Text('12', style: TextStyle(
                                    //               fontSize: 14,
                                    //               color: Colors.black)),
                                    //         ],
                                    //       );
                                    //     },
                                    // ),
                                    SizedBox(height: 2),
                                    Text('${_draftProductCount}', style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black)),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => productManagement()),
                                        );
                                      },
                                      child: Text('Draft',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.white,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 60,
                                width: 80,
                                decoration: BoxDecoration(
                                  // color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border(right: BorderSide(width: 4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 2),
                                    Text('${_activeProductCount}', style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black)),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => productManagement()),
                                        );
                                      },
                                      child: Text('Active',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.white,
                                          )),
                                    ),
                                    // Text('10', style: TextStyle(fontSize: 10)),
                                    // IconButton(
                                    //     onPressed: () {},
                                    //     icon: Icon(Icons.navigate_next),
                                    //     iconSize: 13,
                                    //     color: Colors.white,
                                    // ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 60,
                                width: 80,
                                decoration: BoxDecoration(
                                  // color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border(right: BorderSide(width: 4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 2),
                                    Text('${_deActiveProductCount}', style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black)),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => productManagement()),
                                        );
                                      },
                                      child: Text('Deactive',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.white,
                                          )),
                                    ),
                                    // Text('10', style: TextStyle(fontSize: 10)),
                                    // IconButton(
                                    //     onPressed: () {},
                                    //     icon: Icon(Icons.navigate_next),
                                    //     iconSize: 13,
                                    //     color: Colors.white,
                                    // ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 60,
                                width: 80,
                                decoration: BoxDecoration(
                                  // color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border(right: BorderSide(width: 4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 2),
                                    Text('${_deleteProductCount}', style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black)),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => productManagement()),
                                        );
                                      },
                                      child: Text('Deleted',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.white,
                                          )),
                                    ),
                                    // Text('10', style: TextStyle(fontSize: 10)),
                                    // IconButton(
                                    //     onPressed: () {},
                                    //     icon: Icon(Icons.navigate_next),
                                    //     iconSize: 13,
                                    //     color: Colors.white,
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 160,
                    width: 380,
                    decoration: BoxDecoration(
                      // color: Colors.black,
                      // borderRadius: BorderRadius.circular(5),
                      border: Border(bottom: BorderSide(width: 1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text('Store Performance',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.navigate_next),
                              color: Colors.black,
                              iconSize: 20,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 90,
                                width: 80,
                                decoration: BoxDecoration(
                                  // color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border(right: BorderSide(width: 4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 2),
                                    Text('10.0%', style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black)),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text('Cancel\nRate',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.white,
                                          )),
                                    ),
                                    // Text('10', style: TextStyle(fontSize: 10)),
                                    // IconButton(
                                    //     onPressed: () {},
                                    //     icon: Icon(Icons.navigate_next),
                                    //     iconSize: 13,
                                    //     color: Colors.white,
                                    // ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 90,
                                width: 80,
                                decoration: BoxDecoration(
                                  // color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border(right: BorderSide(width: 4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 2),
                                    Text('75.0%', style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black)),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text('Ship on\nTime',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.white,
                                          )),
                                    ),
                                    // Text('10', style: TextStyle(fontSize: 10)),
                                    // IconButton(
                                    //     onPressed: () {},
                                    //     icon: Icon(Icons.navigate_next),
                                    //     iconSize: 13,
                                    //     color: Colors.white,
                                    // ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 90,
                                width: 80,
                                decoration: BoxDecoration(
                                  // color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border(right: BorderSide(width: 4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 2),
                                    Text('12.50%', style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black)),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text('Return\nRate',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.white,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 90,
                                width: 80,
                                decoration: BoxDecoration(
                                  // color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border(right: BorderSide(width: 4)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(height: 2),
                                    Text('85.0%', style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black)),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text('Reply\nRate',
                                          style: TextStyle(
                                            fontSize: 12,
                                            // color: Colors.white,
                                          )),
                                    ),
                                    // Text('10', style: TextStyle(fontSize: 10)),
                                    // IconButton(
                                    //     onPressed: () {},
                                    //     icon: Icon(Icons.navigate_next),
                                    //     iconSize: 13,
                                    //     color: Colors.white,
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 220,
                    width: 380,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text('Campaign Events',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500)),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.navigate_next),
                              color: Colors.black,
                              iconSize: 20,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 150,
                              width: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(width: 1),
                              ),
                              child: Row(
                                children: [
                                  Image(image: AssetImage('assets/campaign.png'),
                                    width: 140, height: 100,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Text('Stitch Hub 3.3\nSale Campaign',
                                          style: TextStyle(fontSize: 13)),
                                      SizedBox(height: 10),
                                      Container(
                                        height: 20,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Center(
                                          child: TextButton(
                                            onPressed: () {},
                                            child: Text('JOIN NOW',
                                                style: TextStyle(fontSize: 8.5, color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Text('Registration Ends:',
                                          style: TextStyle(fontSize: 7)),
                                      SizedBox(height: 5),
                                      Container(
                                        height: 15,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Center(
                                          child: Text('21 March 2024',
                                              style: TextStyle(fontSize: 5.5, color: Colors.white)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 45),
                  Center(child: Text('Stitch Hub ® 2024 - All Rights Reserved.')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class ProductCountWidget extends StatelessWidget {
//   final Stream<Map<String, int>> productCountsStream;
//
//   ProductCountWidget({required this.productCountsStream});
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return Text('User not logged in');
//     }
//     final sellerId = user.uid;
//     return StreamBuilder<Map<String, int>>(
//         stream: FirebaseFirestore.instance.collection('sellers').doc(sellerId).snapshots().map((snapshot) {
//           final data = snapshot.data();
//           if (data == null) return {};
//           return {
//             'drafts': data['drafts'] ?? 0,
//             'active': data['active'] ?? 0,
//             'deactive': data['deactive'] ?? 0,
//             'rejected': data['rejected'] ?? 0,
//           };
//         }),
//         builder: (context, snapshot) {
//           // if (snapshot.connectionState == ConnectionState.waiting) {
//           //   return CircularProgressIndicator();
//           // }
//           if (snapshot.hasError) {
//             return Text('Error: ${snapshot.error}');
//           }
//           final counts = snapshot.data ?? {};
//           return Column(
//             children: [
//               // Text('Drafts: ${counts['drafts']}'),
//               // Text('Active: ${counts['active']}'),
//               // Text('Deactive: ${counts['deactive']}'),
//               // Text('Rejected: ${counts['rejected']}'),
//             ],
//           );
//         }
//     );
//   }
// }


class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text('Messages',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: Container(
                  height: 50,
                  width: 350,
                  child: TextFormField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                        hintText: 'Search ...',
                        hintStyle: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.7)),
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.filter_alt),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Color(0xFF6C63FF)),
                            borderRadius: BorderRadius.circular(30)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black.withOpacity(0.7)),
                            borderRadius: BorderRadius.circular(30)),
                        // border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15, right: 15)
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 5, top: 7),
                // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: tCardByColor),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.add),
                  color: Colors.black,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 5, top: 7),
                // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: tCardByColor),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_horiz),
                  color: Colors.black,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  bool isDarkMode = false;
  bool isSilentMode = false;
  late String _ownerName = '';
  late String _userName = '';
  late String _email = '';
  late String _phoneNum = '';
  // File? _sellerImageFile;
  // final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _sellerImage;

  Future<String> uploadImage(File imageFile) async {
    String imageURL;
    try {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('sellerProfile/$imageName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      imageURL = await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      alertMessage.showAlert(context, 'Error', 'Error uploading image: $e');
      imageURL = '';
    }
    return imageURL;
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);

    try {
      if(img != null) {
        setState(() {
          _sellerImage = img;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image Successfully Uploaded!'),
            ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select an image file.'),
            ));
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image.'),
          ));
    }
  }

  // Future<void> _selectImage() async {
  //
  //   try{
  //     final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
  //     if (pickedFile != null) {
  //       final File imageFile = File(pickedFile.path);
  //       final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
  //       if (decodedImage != null) {
  //         setState(() {
  //           _sellerImageFile = imageFile;
  //         });
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Please select an image file.'),
  //             ));
  //       }
  //     }
  //   } catch (e) {
  //     print('Error picking image: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error picking image.'),
  //         ));
  //   }
  //   // final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
  //   // if (pickedFile != null) {
  //   //   setState(() {
  //   //     _sellerImageFile = File(pickedFile.path);
  //   //   });
  //   // }
  // }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  
  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('sellers').doc(email).get();

      setState(() {
        _ownerName = userData['ownerName'];
        _userName = userData['userame'];
        _email = userData['email'];
        _phoneNum = userData['phoneNum'];
      });
    }
  }

  Future<void> _signout() async {
    try{
      await FirebaseAuth.instance.signOut();
      Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser!;
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                // Container(
                //   height: 30,
                //   width: 30,
                //   decoration: BoxDecoration(
                //     color: Colors.black,
                //     borderRadius: BorderRadius.circular(2),
                //   ),
                //   child: IconButton(
                //       onPressed: () {
                //         Navigator.of(context).pop();
                //       },
                //       icon: Icon(Icons.navigate_before_outlined),
                //       iconSize: 15,
                //       color: Colors.white
                //   ),
                // ),
                SizedBox(width: 5),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text('User Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: IconButton(
                    onPressed: () {

                    },
                    icon: Icon(Icons.question_mark_rounded),
                    iconSize: 20,
                    color: Colors.black
                ),
                // Container(
                //   height: 30,
                //   width: 30,
                //   decoration: BoxDecoration(
                //     color: Colors.black,
                //     borderRadius: BorderRadius.circular(2),
                //   ),
                //   child: IconButton(
                //       onPressed: () {
                //
                //       },
                //       icon: Icon(Icons.question_mark),
                //       iconSize: 15,
                //       color: Colors.white
                //   ),
                // ),
              ),
            ],
          ),
          body: Container(
            color: Colors.cyanAccent.withOpacity(0.1),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      height: 100,
                      width: 400,
                      decoration: BoxDecoration(
                        // border: Border.all(
                        //   color: Colors.black,
                        //   width: 2.0,
                        // ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                        height: 70,
                        width: 380,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: 15),
                                Stack(
                                  children: [
                                    _sellerImage != null ?
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundImage: MemoryImage(_sellerImage!),
                                    )
                                        : CircleAvatar(
                                      radius: 35,
                                      backgroundImage: NetworkImage('https://as2.ftcdn.net/v2/jpg/05/49/98/39/1000_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'),
                                    ),
                                    Positioned(
                                      child: IconButton(
                                        onPressed: () {
                                          selectImage();
                                        },
                                        icon: Icon(Icons.add_a_photo, size: 20),
                                      ),
                                      bottom: -12,
                                      left: 35,
                                    )
                                  ],
                                ),
                                // Container(
                                //   child: GestureDetector(
                                //     onTap: () {
                                //       _selectImage();
                                //     },
                                //     child: CircleAvatar(
                                //       radius: 30,
                                //       backgroundColor: Colors.grey.shade300,
                                //       backgroundImage: _sellerImageFile != null ? FileImage(_sellerImageFile!) : null,
                                //       child: _sellerImageFile == null
                                //           ? Icon(
                                //         Icons.account_circle,
                                //         size: 60,
                                //         color: Colors.grey,
                                //       ) : null,
                                //     ),
                                //   ),
                                // ),
                                SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$_ownerName', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
                                    // Text('$_userName', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
                                    Text('Full Name', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.5))),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Center(
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => profileChange()),
                                      );
                                    },
                                    icon: Icon(Icons.navigate_next),
                                    iconSize: 25,
                                    color: Colors.black
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('About Me', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      height: 350,
                      width: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: 5),
                          Container(
                            height: 70,
                            width: 380,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(1),
                              border: Border(bottom: BorderSide(width: 1, color: Colors.black.withOpacity(0.3))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Icon(Icons.person, size: 35),
                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$_userName'),
                                        Text('Username', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.5))),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: IconButton(
                                      onPressed: () {

                                      },
                                      icon: Icon(Icons.navigate_next),
                                      iconSize: 25,
                                      color: Colors.black
                                  ),
                                  // Container(
                                  //   height: 30,
                                  //   width: 30,
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.black,
                                  //     borderRadius: BorderRadius.circular(2),
                                  //   ),
                                  //   child: IconButton(
                                  //       onPressed: () {
                                  //
                                  //       },
                                  //       icon: Icon(Icons.navigate_next),
                                  //       iconSize: 15,
                                  //       color: Colors.white
                                  //   ),
                                  // ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            height: 70,
                            width: 380,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(5),
                              border: Border(bottom: BorderSide(width: 1, color: Colors.black.withOpacity(0.3))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Icon(Icons.mail, size: 35),
                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$_email'),
                                        Text('Email Address', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.5))),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: IconButton(
                                      onPressed: () {

                                      },
                                      icon: Icon(Icons.navigate_next),
                                      iconSize: 25,
                                      color: Colors.black
                                  ),
                                  // Container(
                                  //   height: 30,
                                  //   width: 30,
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.black,
                                  //     borderRadius: BorderRadius.circular(2),
                                  //   ),
                                  //   child: IconButton(
                                  //       onPressed: () {
                                  //
                                  //       },
                                  //       icon: Icon(Icons.navigate_next),
                                  //       iconSize: 15,
                                  //       color: Colors.white
                                  //   ),
                                  // ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            height: 70,
                            width: 380,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(5),
                              border: Border(bottom: BorderSide(width: 1, color: Colors.black.withOpacity(0.3))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Icon(Icons.phone, size: 35),
                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('$_phoneNum'),
                                        Text('Phone Number', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.5))),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: IconButton(
                                      onPressed: () {

                                      },
                                      icon: Icon(Icons.navigate_next),
                                      iconSize: 25,
                                      color: Colors.black
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            height: 70,
                            width: 380,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(5),
                              border: Border(bottom: BorderSide(width: 1, color: Colors.black.withOpacity(0.3))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Icon(Icons.location_on, size: 35),
                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('123 Anywhere St 12'),
                                        Text('Address', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.5))),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: IconButton(
                                      onPressed: () {

                                      },
                                      icon: Icon(Icons.navigate_next),
                                      iconSize: 25,
                                      color: Colors.black
                                  ),
                                  // Container(
                                  //   height: 30,
                                  //   width: 30,
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.black,
                                  //     borderRadius: BorderRadius.circular(2),
                                  //   ),
                                  //   child: IconButton(
                                  //       onPressed: () {
                                  //
                                  //       },
                                  //       icon: Icon(Icons.navigate_next),
                                  //       iconSize: 15,
                                  //       color: Colors.white
                                  //   ),
                                  // ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Setting', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      height: 350,
                      width: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: 5),
                          Container(
                            height: 70,
                            width: 380,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(5),
                              border: Border(bottom: BorderSide(width: 1, color: Colors.black.withOpacity(0.3))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Icon(Icons.language_sharp, size: 35),
                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('English'),
                                        Text('Language', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.5))),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: IconButton(
                                      onPressed: () {

                                      },
                                      icon: Icon(Icons.navigate_next),
                                      iconSize: 25,
                                      color: Colors.black
                                  ),
                                  // Container(
                                  //   height: 30,
                                  //   width: 30,
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.black,
                                  //     borderRadius: BorderRadius.circular(2),
                                  //   ),
                                  //   child: IconButton(
                                  //       onPressed: () {
                                  //
                                  //       },
                                  //       icon: Icon(Icons.navigate_next),
                                  //       iconSize: 15,
                                  //       color: Colors.white
                                  //   ),
                                  // ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            height: 70,
                            width: 380,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(5),
                              border: Border(bottom: BorderSide(width: 1, color: Colors.black.withOpacity(0.3))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    isSilentMode
                                        ? Icon(Icons.volume_up, size: 35,
                                        color: Colors.black)
                                        : Icon(Icons.volume_off, size: 35, color: Colors.black),
                                    // Icon(Icons.mail, size: 35),
                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Text('Silent Mode'),
                                        Text(
                                          isSilentMode ? 'Active Mode' : 'Silent Mode',
                                          style: TextStyle(
                                            color: isSilentMode ? Colors.black : Colors.black,
                                          ),
                                        ),
                                        Text('Notification & Message', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.5))),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isSilentMode = !isSilentMode;
                                      });
                                    },
                                    child: isSilentMode
                                        ? Icon(Icons.toggle_on_outlined,
                                        color: Colors.black, size: 50)
                                        : Icon(Icons.toggle_off_outlined,
                                        color: Colors.black, size: 50),
                                    // child: AnimatedContainer(
                                    //   // height: 50,
                                    //   // width: 40,
                                    //   duration: Duration(milliseconds: 300),
                                    //   constraints: BoxConstraints(
                                    //     maxHeight: 20,
                                    //     maxWidth: 30
                                    //   ),
                                    //   padding: EdgeInsets.all(8.0),
                                    //   decoration: BoxDecoration(
                                    //     color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                    //     borderRadius: BorderRadius.circular(20.0),
                                    //   ),
                                    //   child: Row(
                                    //     mainAxisAlignment: isDarkMode
                                    //         ? MainAxisAlignment.end
                                    //         : MainAxisAlignment.start,
                                    //     children: [
                                    //       isDarkMode
                                    //           ? Icon(Icons.toggle_on_outlined,
                                    //           color: Colors.white)
                                    //           : Icon(Icons.toggle_off_outlined,
                                    //           color: Colors.black),
                                    //       // SizedBox(width: 8.0),
                                    //       // Text(
                                    //       //   isDarkMode ? 'Dark ' : 'Light Mode',
                                    //       //   style: TextStyle(
                                    //       //     color: isDarkMode ? Colors.white : Colors.black,
                                    //       //   ),
                                    //       // ),
                                    //       SizedBox(width: 8.0),
                                    //       // isDarkMode
                                    //       //     ? Icon(Icons.wb_sunny, color: Colors.black)
                                    //       //     : Icon(Icons.nightlight_round,
                                    //       //     color: Colors.white),
                                    //     ],
                                    //   ),
                                    // ),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(right: 10),
                                //   child: Container(
                                //     height: 30,
                                //     width: 30,
                                //     decoration: BoxDecoration(
                                //       color: Colors.black,
                                //       borderRadius: BorderRadius.circular(2),
                                //     ),
                                //     child: IconButton(
                                //         onPressed: () {
                                //
                                //         },
                                //         icon: Icon(Icons.navigate_next),
                                //         iconSize: 15,
                                //         color: Colors.white
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            height: 70,
                            width: 380,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(5),
                              border: Border(bottom: BorderSide(width: 1, color: Colors.black.withOpacity(0.3))),
                            ),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    isDarkMode
                                        ? Icon(Icons.nightlight_round, size: 35,
                                        color: Colors.white)
                                        : Icon(Icons.wb_sunny, size: 35, color: Colors.black),
                                    // Icon(Icons.phone, size: 35),
                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Text('Light Mode'),
                                        Text(
                                          isDarkMode ? 'Dark Mode' : 'Light Mode',
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        Text('Theme', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.5))),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 200),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isDarkMode = !isDarkMode;
                                      });
                                    },
                                    child: isDarkMode
                                        ? Icon(Icons.toggle_on_outlined,
                                        color: Colors.black, size: 50)
                                        : Icon(Icons.toggle_off_outlined,
                                        color: Colors.black, size: 50),
                                    // child: AnimatedContainer(
                                    //   // height: 50,
                                    //   // width: 40,
                                    //   duration: Duration(milliseconds: 300),
                                    //   constraints: BoxConstraints(
                                    //     maxHeight: 20,
                                    //     maxWidth: 30
                                    //   ),
                                    //   padding: EdgeInsets.all(8.0),
                                    //   decoration: BoxDecoration(
                                    //     color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                    //     borderRadius: BorderRadius.circular(20.0),
                                    //   ),
                                    //   child: Row(
                                    //     mainAxisAlignment: isDarkMode
                                    //         ? MainAxisAlignment.end
                                    //         : MainAxisAlignment.start,
                                    //     children: [
                                    //       isDarkMode
                                    //           ? Icon(Icons.toggle_on_outlined,
                                    //           color: Colors.white)
                                    //           : Icon(Icons.toggle_off_outlined,
                                    //           color: Colors.black),
                                    //       // SizedBox(width: 8.0),
                                    //       // Text(
                                    //       //   isDarkMode ? 'Dark ' : 'Light Mode',
                                    //       //   style: TextStyle(
                                    //       //     color: isDarkMode ? Colors.white : Colors.black,
                                    //       //   ),
                                    //       // ),
                                    //       SizedBox(width: 8.0),
                                    //       // isDarkMode
                                    //       //     ? Icon(Icons.wb_sunny, color: Colors.black)
                                    //       //     : Icon(Icons.nightlight_round,
                                    //       //     color: Colors.white),
                                    //     ],
                                    //   ),
                                    // ),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(right: 10),
                                //   child: Container(
                                //     height: 30,
                                //     width: 30,
                                //     decoration: BoxDecoration(
                                //       color: Colors.black,
                                //       borderRadius: BorderRadius.circular(2),
                                //     ),
                                //     child: IconButton(
                                //         onPressed: () {
                                //
                                //         },
                                //         icon: Icon(Icons.navigate_next),
                                //         iconSize: 15,
                                //         color: Colors.white
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            height: 70,
                            width: 380,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(5),
                              border: Border(bottom: BorderSide(width: 1, color: Colors.black.withOpacity(0.3))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Icon(Icons.storage, size: 35),
                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('High Quality'),
                                        Text('Mobile Data Settings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.5))),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Container(
                      height: 50,
                      width: 400,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _signout();
                                },
                                icon: Icon(Icons.logout),
                              ),
                              SizedBox(width: 5),
                              Text('Logout', style: TextStyle(color: Colors.black, fontSize: 15)),
                            ],
                          ),
                          TextButton(
                              onPressed: () {},
                              child: Text('Term & Conditions', style: TextStyle(fontSize: 8))
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
      // appBar: AppBar(
      //   title: Text('User Profile'),
      //   centerTitle: true,
      //   actions: [
      //     TextButton(
      //         onPressed: () {},
      //         child: Text('Logout'),
      //     ),
      //   ],
      // ),
      // body: SingleChildScrollView(
      //   child: Container(
      //     alignment: Alignment.center,
      //     // color: Colors.blueGrey.shade900,
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Text('Profile', style: TextStyle(fontSize: 24)),
      //         SizedBox(height: 32),
      //         // CircleAvatar(
      //         //   radius: 40,
      //         //   backgroundImage: NetworkImage(user.photoURL!),
      //         // ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}

class Notification extends StatefulWidget {
  const Notification({super.key});

  @override
  State<Notification> createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
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
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text('Notifications',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Order'),
                Tab(text: 'Product'),
                Tab(text: 'Store'),
                Tab(text: 'Bidding'),
              ],
              isScrollable: true,
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 5, top: 7),
                // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: tCardByColor),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.settings),
                  color: Colors.black,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 5, top: 7),
                // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: tCardByColor),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.filter_alt),
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              child: Center(
                child: Text('No Order Notification'),
              ),
            ),
            Container(
              child: Center(
                child: Text('No Product Notification'),
              ),
            ),
            Container(
              child: Center(
                child: Text('No Store Notification'),
              ),
            ),
            Container(
              child: Center(
                child: Text('No Bidding Notification'),
              ),
            ),
          ],
        ),
        // SingleChildScrollView(
        //   child: Column(
        //     // mainAxisAlignment: MainAxisAlignment.center,
        //     // crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       SizedBox(height: 10),
        //       Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 15),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Container(
        //               height: 40,
        //               width: 80,
        //               decoration: BoxDecoration(
        //                 color: Colors.black.withOpacity(0.4),
        //                 borderRadius: BorderRadius.circular(100),
        //               ),
        //               child: TextButton(
        //                 onPressed: () {},
        //                 child: Text('Orders', style: TextStyle(color: Colors.white)),
        //               ),
        //             ),
        //             Container(
        //               height: 40,
        //               width: 80,
        //               decoration: BoxDecoration(
        //                 color: Colors.black.withOpacity(0.4),
        //                 borderRadius: BorderRadius.circular(100),
        //               ),
        //               child: TextButton(
        //                 onPressed: () {},
        //                 child: Text('Alerts', style: TextStyle(color: Colors.white)),
        //               ),
        //             ),
        //             Container(
        //               height: 40,
        //               width: 80,
        //               decoration: BoxDecoration(
        //                 color: Colors.black.withOpacity(0.4),
        //                 borderRadius: BorderRadius.circular(100),
        //               ),
        //               child: TextButton(
        //                 onPressed: () {},
        //                 child: Text('Promos', style: TextStyle(color: Colors.white)),
        //               ),
        //             ),
        //             Container(
        //               height: 40,
        //               width: 80,
        //               decoration: BoxDecoration(
        //                 color: Colors.black.withOpacity(0.4),
        //                 borderRadius: BorderRadius.circular(100),
        //               ),
        //               child: TextButton(
        //                 onPressed: () {},
        //                 child: Text('Sales', style: TextStyle(color: Colors.white)),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // bool isLiked = false;
  // bool isSaved = false;
  // bool isFavorite = false;
  // bool isExpanded = false;

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
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text('Home Page',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 5, top: 7),
                // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: tCardByColor),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.filter_list_outlined),
                  color: Colors.black,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 5, top: 7),
                // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: tCardByColor),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.question_mark_rounded),
                  color: Colors.black,
                ),
              ),
            ],
          ),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('buyers').snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Unauthorized User'));
              } else if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                var buyers = snapshot.data.docs;
                return SingleChildScrollView(
                  child: Column(
                    children: buyers.map<Widget>((buyer) {
                      String buyerEmail = buyer['email'];
                      String buyerUsername = buyer['username'];
                      String buyerName = buyer['fullName'];
                      return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('buyers')
                              .doc(buyer.id) // Seller ID
                              .collection('posts')
                              .get(),
                          builder: (context, AsyncSnapshot postSnapshot) {
                            if (postSnapshot.hasError) {
                              return Text('Error: ${postSnapshot.error}');
                            } else if (!postSnapshot.hasData) {
                              return SizedBox();
                            } else {
                              var posts = postSnapshot.data.docs;
                              return Column(
                                children: posts.map<Widget>((post) {
                                  String description = post['description'];
                                  String imageUrl1 = post['imageUrl'] ?? '';

                                  return PostCard(
                                    buyerEmail: buyerEmail,
                                    buyerName: buyerName,
                                    buyerUsername: buyerUsername,
                                    description: description,
                                    imageUrl: imageUrl1,
                                  );

                                }).toList(),
                              );
                            }
                          }
                      );
                    }).toList(),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String buyerEmail;
  final String buyerName;
  final String buyerUsername;
  final String description;
  final String imageUrl;

  PostCard({
    required this.buyerEmail,
    required this.buyerName,
    required this.buyerUsername,
    required this.description,
    required this.imageUrl,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  bool isLiked = false;
  bool isSaved = false;
  bool isFavorite = false;
  bool isExpanded = false;
  String duration = '';
  String amount = '';

  late String _storeName = '';
  late String _username = '';

  Future<void> bidOnPost(String bidAmount, String bidDuration, String buyerEmail, String buyerName, String buyerUsername, String description, String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? sellerId = user?.email;
    String buyerId = buyerEmail;

    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('sellers').doc(sellerId).get();

      setState(() {
        _storeName = userData['storeName'];
        _username = userData['userame'];
      });
    }

    FirebaseFirestore.instance.collection('buyers').doc(buyerId).collection('Bid Post').add({
      'Store Email': sellerId,
      'Buyer Email': buyerId,
      'Store Username': _username,
      'Buyer Username': buyerUsername,
      'Store Name': _storeName,
      'Buyer Name': buyerName,
      'Bid Amount': bidAmount,
      'Duration': bidDuration,
      'Description': description,
      'Image': imageUrl,
      'time': FieldValue.serverTimestamp(),
    });

    FirebaseFirestore.instance.collection('sellers').doc(sellerId).collection('Bid Post').add({
      'Store Email': sellerId,
      'Buyer Email': buyerId,
      'Store Username': _username,
      'Buyer Username': buyerUsername,
      'Store Name': _storeName,
      'Buyer Name': buyerName,
      'Bid Amount': bidAmount,
      'Duration': bidDuration,
      'Description': description,
      'Image': imageUrl,
      'time': FieldValue.serverTimestamp(),
    });

    alertMessage.showAlert(context, 'Success', 'You have Successfully Bid on Post.');

  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isExpanded ? 280 : 200,
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
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: widget.imageUrl != null
                    ? NetworkImage(widget.imageUrl)
                    : NetworkImage('https://as2.ftcdn.net/v2/jpg/05/49/98/39/1000_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'),
              ),
              SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.buyerName, style: TextStyle(color: Colors.black, fontSize: 16)),
                    Text(widget.buyerUsername, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            height: 80,
            child: Text(widget.description, style: TextStyle(fontSize: 20)),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  RoundedIconButton(
                    icon: Icons.thumb_up,
                    color: isLiked ? Colors.red : Colors.white,
                    onPressed: () {
                      setState(() {
                        isLiked = !isLiked;
                      });
                    },
                  ),
                  SizedBox(width: 5),
                  RoundedIconButton(
                    icon: Icons.bookmark,
                    color: isSaved ? Colors.red : Colors.white,
                    onPressed: () {
                      setState(() {
                        isSaved = !isSaved;
                      });
                    },
                  ),
                  SizedBox(width: 5),
                  RoundedIconButton(
                    icon: Icons.favorite,
                    color: isFavorite ? Colors.red : Colors.white,
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                  ),
                ],
              ),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
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
            ],
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        suffix: Text('Rs'),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          amount = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      decoration: InputDecoration(
                        labelText: 'Duration',
                        suffix: Text('Day'),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          duration = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
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
                            bidOnPost(amount, duration, widget.buyerEmail, widget.buyerName, widget.buyerUsername, widget.description, widget.imageUrl);
                          },
                          child: Text("Bid"),
                      ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


class RoundedIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const RoundedIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 14),
        onPressed: onPressed,
      ),
    );
  }
}

class alertMessage{

  static void showAlert(BuildContext context, String title, String message){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

