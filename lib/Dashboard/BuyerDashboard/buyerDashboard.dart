import 'dart:io';
import 'dart:core';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/categoryView.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/shoppingCart.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/viewAllProduct.dart';
import 'package:stitchhub_app/Dashboard/changeProfile.dart';
import 'package:stitchhub_app/Dashboard/imagePicker.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/productListScreen.dart';
import 'package:stitchhub_app/UserAuthentication/login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitchhub_app/Dashboard/inAppMessaging.dart';

class buyerDashboard extends StatefulWidget {
  const buyerDashboard({super.key});

  @override
  State<buyerDashboard> createState() => _buyerDashboardState();
}

class _buyerDashboardState extends State<buyerDashboard> {

  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    Inbox(),
    Post(),
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
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  // backgroundColor: Colors.white,
                  icon: Icon(Icons.mail),
                  label: 'Inbox',
                ),
                BottomNavigationBarItem(
                  // backgroundColor: Colors.white,
                  icon: Icon(Icons.add_box_rounded),
                  label: 'Post',
                ),
                BottomNavigationBarItem(
                  // backgroundColor: Colors.white,
                  icon: Icon(Icons.notification_important_rounded),
                  label: 'Notification',
                ),
                BottomNavigationBarItem(
                  // backgroundColor: Colors.white,
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ]
          ),
        ),
      ),
    );
  }
}

class Product {
  final String title;
  final String description;
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
    required this.description,
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

  factory Product.fromFirestore(DocumentSnapshot doc, String storeName, String phoneNum, String email) {
    Map data = doc.data() as Map;
    return Product(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl1'] ?? '',
      imageURL2: data['imageUrl2'] ?? '',
      imageURL3: data['imageUrl3'] ?? '',
      imageURL4: data['imageUrl4'] ?? '',
      price: data['saleCost'] != null ? int.parse(data['saleCost']) : 0,
      comparePrice: data['compareCost'] != null ? int.parse(data['compareCost']) : 0,
      storeName: storeName,
      phoneNum: phoneNum,
      email: email,
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // final ScrollController _scrollController1 = ScrollController();
  // final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Product> _searchResults = [];
  List<String> _searchHistory = [];
  List<String> _recommendedSearches = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int cartCount = 0;
  String selectedSize = 'S';
  int currentIndex = 0;

  File? _scanImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _fetchSearchHistory();
    // _fetchRecommendedSearches();
    _fetchCartCount();
    _fetchCategories();
    // _scrollController1.addListener(() {
    //   _scrollController2.jumpTo(_scrollController1.offset);
    // });
    // _scrollController2.addListener(() {
    //   _scrollController1.jumpTo(_scrollController2.offset);
    // });
  }

  String getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception("No user is currently logged in.");
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && searchController.text.isEmpty) {
      _generateRecommendedSearches();
    }
    setState(() {});
  }

  void _fetchSearchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    String? userId = user?.email;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('buyers')
          .doc(userId)
          .collection('search history')
          .orderBy('time', descending: true)
          .limit(5)
          .get();

      setState(() {
        _searchHistory = snapshot.docs.map((doc) => doc['title'] as String).toList();
      });
    }
  }

  void _generateRecommendedSearches() async {
    final user = FirebaseAuth.instance.currentUser;
    String? userId = user?.email;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('buyers')
          .doc(userId)
          .collection('search history')
          .get();

      final searchHistoryTitles = snapshot.docs.map((doc) => doc['title'] as String).toList();
      final keywords = searchHistoryTitles.expand((title) => title.split(' ')).toSet().toList();

      List<String> recommendedTitles = [];
      for (String keyword in keywords) {
        final productSnapshot = await FirebaseFirestore.instance
            .collectionGroup('active product')
            .where('title', isGreaterThanOrEqualTo: keyword)
            .where('title', isLessThanOrEqualTo: '$keyword\uf8ff')
            .limit(5)
            .get();

        for (var doc in productSnapshot.docs) {
          recommendedTitles.add(doc['title']);
        }
      }

      setState(() {
        _recommendedSearches = recommendedTitles.toSet().toList(); // Remove duplicates
      });
    }
  }
  //
  // void _fetchRecommendedSearches() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   String? userId = user?.email;
  //   if (user != null) {
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('buyers')
  //         .doc(userId)
  //         .collection('search history')
  //         .get();
  //
  //     setState(() {
  //       _recommendedSearches = snapshot.docs.map((doc) => doc['title'] as String).toList();
  //     });
  //   }
  // }

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

  void addToCart(String title, int saleprice, int compareprice, String description, String storename, String storePhoneNo, String storeEmail, String image1, String image2, String image3, String image4) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userCartId = user?.email;

    FirebaseFirestore.instance.collection('buyers').doc(userCartId).collection('cart').add({
      'product title': title,
      'product price': saleprice,
      'discount price': compareprice,
      'product description': description,
      'store name': storename,
      'store phoneNo': storePhoneNo,
      'store email': storeEmail,
      'quantity': 1,
      'product size': selectedSize,
      'imageUrl1': image1,
      'imageUrl2': image2,
      'imageUrl3': image3,
      'imageUrl4': image4,
      'time': FieldValue.serverTimestamp(),
    });
  }

  Future<void> searchHistory(String title, int price, String storeName) async {

    try{

      User? user = _auth.currentUser;
      String? userId = user?.email;

      if (userId == null) {
        print('No user logged in');
        return;
      } else {
        FirebaseFirestore.instance.collection('buyers').doc(userId).collection('search history').add({
          'title': title,
          'price range': price,
          'store name': storeName,
          'time': FieldValue.serverTimestamp(),
        });
      }
      print("History is stored");
    } catch (e) {
      print('Error Store History: $e');
    }
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final List<Product> searchResults = [];

    FirebaseFirestore.instance.collection('sellers').get().then((querySnapshot) {
      querySnapshot.docs.forEach((sellerDoc) {

        FirebaseFirestore.instance
            .collection('sellers')
            .doc(sellerDoc.id)
            .collection('active product')
            .get()
            .then((productSnapshot) {
          productSnapshot.docs.forEach((productDoc) {
            String title = productDoc['title'];
            int price = int.parse(productDoc['saleCost']);
            String imageUrl = productDoc['imageUrl1'] ?? '';
            String description = productDoc['description'] ?? '';
            int comparePrice = int.parse(productDoc['compareCost']);
            String storeName = sellerDoc['storeName'] ?? '';
            String phoneNum = sellerDoc['phoneNum'] ?? '';
            String email = sellerDoc['email'] ?? '';
            String imageURL2 = productDoc['imageUrl2'] ?? '';
            String imageURL3 = productDoc['imageUrl3'] ?? '';
            String imageURL4 = productDoc['imageUrl4'] ?? '';

            if (title.toLowerCase().contains(query.toLowerCase())) {
              searchResults.add(Product(title: title, description: description, price: price, comparePrice: comparePrice, storeName: storeName, phoneNum: phoneNum, email: email, imageUrl: imageUrl, imageURL2: imageURL2, imageURL3: imageURL3, imageURL4: imageURL4));
            }
          });

          setState(() {
            _searchResults = searchResults; // Update the state with search results
          });
        }).catchError((error) {
          print('Error fetching products: $error');
        });
      });
    }).catchError((error) {
      print('Error fetching sellers: $error');
    });
  }

  Future<Map<String, String>> _fetchCategories() async {
    Map<String, String> categories = {};

    var sellerSnapshots = await FirebaseFirestore.instance.collection('sellers').get();
    for (var sellerDoc in sellerSnapshots.docs) {
      var productsSnapshot = await sellerDoc.reference.collection('active product').get();
      for (var productDoc in productsSnapshot.docs) {
        String category = productDoc['category'];
        String imageUrl = productDoc['imageUrl1'] ?? 'assets/default_image.jpg';
        if (!categories.containsKey(category)) {
          categories[category] = imageUrl;
        }
      }
    }
    return categories;
  }

  void _selectGalleryImage() async {

    final imagePicker = await picker.pickImage(source: ImageSource.gallery);

  }

  void _selectCameraImage() async {

    final imagePicker = await picker.pickImage(source: ImageSource.camera);

  }

  void _showVisualSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            height: 180,
            // color: Colors.white,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(child: Text('Search any image with Lens', style: TextStyle(fontWeight: FontWeight.w400))),
                      Container(
                        height: 130,
                        width: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Image(image: AssetImage('assets/galleryIcon.png')),
                                ),
                                TextButton(
                                    onPressed: () {
                                      _selectGalleryImage();
                                    },
                                    child: Text("upload a file", style: TextStyle(decoration: TextDecoration.underline)),
                                ),
                                Text("or"),
                                TextButton(
                                  onPressed: () {
                                    _selectCameraImage();
                                  },
                                  child: Text("take picture", style: TextStyle(decoration: TextDecoration.underline)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Colors.red,
                        // shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    // _scrollController1.dispose();
    // _scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.email;
    final String buyerId = getCurrentUserId();
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Stitch',
                          style: TextStyle(fontFamily: 'Ubuntu', fontSize: 22, color: Colors.black),
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
                SizedBox(width: 25.w),
                Container(
                  height: 45.h,
                  width: 150.w,
                  child: Center(
                    child: TextFormField(
                      controller: searchController,
                      focusNode: _focusNode,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                          hintText: 'Search here',
                          hintStyle: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.7)),
                          suffixIcon: IconButton(
                              onPressed: () {
                                _showVisualSearchDialog();
                              },
                              icon: const Image(image: AssetImage('assets/visualSearch.png'))),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                              BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10)),
                          // border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 12.0)),
                      onChanged: (value) {
                        searchProducts(value);
                      },
                    ),
                  ),
                ),
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
                        height: 22.h,
                        width: 22.w,
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
          // backgroundColor: Color(0XFFDBE3EB),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 30.h,
                                width: 60.w,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Text(
                                    'Men',
                                    style:
                                    TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                height: 30.h,
                                width: 60.w,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Text(
                                    'Women',
                                    style:
                                    TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                height: 30.h,
                                width: 60.w,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Text(
                                    'Kid',
                                    style:
                                    TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                height: 30.h,
                                width: 60.w,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Text(
                                    'Elder',
                                    style:
                                    TextStyle(fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'View All',
                                  style:
                                  TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('CATEGORY', style: TextStyle(fontFamily: 'Ubuntu', fontSize: 17, fontWeight: FontWeight.bold)),
                            // TextButton(
                            //   onPressed: () {
                            //     // Navigator.push(
                            //     //   context,
                            //     //   MaterialPageRoute(builder: (context) => viewAllProduct()),
                            //     // );
                            //   },
                            //   child: Text('View All'),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 330.w,
                        child: FutureBuilder(
                          future: _fetchCategories(),
                          builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              var categories = snapshot.data!;
                              List<MapEntry<String, String>> categoryList = categories.entries.toList();

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: categoryList.map((category) {
                                    return _buildCategoryItem(category.key, category.value);
                                  }).toList(),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 350.h,
                        height: 200.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                              image: AssetImage('assets/mainCover.jpg'),
                              fit: BoxFit.fill
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get your own cloths and style!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Container(
                                height: 35.h,
                                width: 60.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => viewAllProduct()),
                                    );
                                  },
                                  child: Center(
                                    child: Text(
                                      'More',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Recent Posts', style: TextStyle(fontFamily: 'Ubuntu', fontSize: 17)),
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
                                  // deleteActiveProduct(userId, productId);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                            height: 220.h,
                            width: 330.w,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1.0,
                              ),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance.collection("buyers").doc(userId).collection("posts").snapshots(),
                              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> postSnapshot) {
                                if (postSnapshot.hasData && postSnapshot.data != null) {
                                  if (postSnapshot.data!.docs.isNotEmpty) {
                                    var posts = postSnapshot.data!.docs;

                                    return Padding(
                                      padding: const EdgeInsets.only(left: 10, top: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          StreamBuilder(
                                            stream: FirebaseFirestore.instance.collection("buyers").doc(userId).snapshots(),
                                            builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                                              if (snapshot.hasData && snapshot.data != null) {
                                                Map<String, dynamic> userData = snapshot.data!.data() ?? {};
                                                String username = userData['username'] ?? 'Unknown';
                                                String buyerName = userData['fullName'] ?? 'Unknown';
                                                return Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 22,
                                                      backgroundImage: NetworkImage('https://as2.ftcdn.net/v2/jpg/05/49/98/39/1000_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 2),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('$buyerName', style: TextStyle(color: Colors.black, fontSize: 16)),
                                                          Text('$username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return SizedBox();
                                              }
                                            },
                                          ),
                                          SizedBox(height: 5),
                                          SizedBox(
                                            height: 150, // Adjust height as needed
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  onPressed: currentIndex > 0 ? () => setState(() => currentIndex--) : null,
                                                  icon: Icon(Icons.navigate_before),
                                                ),
                                                Expanded(
                                                  child: Center(
                                                    child: posts.isNotEmpty
                                                        ? Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(posts[currentIndex]['description'] ?? '', style: TextStyle(fontSize: 18)),
                                                      ],
                                                    )
                                                        : Text('No posts available'),
                                                  ),
                                                ),
                                                // SizedBox(height: 10),
                                                posts[currentIndex]['imageUrl'] != null && posts[currentIndex]['imageUrl'].isNotEmpty
                                                    ? Container(height: 70, width: 70, child: Image.network(posts[currentIndex]['imageUrl'], fit: BoxFit.cover))
                                                    : SizedBox(),
                                                IconButton(
                                                  onPressed: currentIndex < posts.length - 1 ? () => setState(() => currentIndex++) : null,
                                                  icon: Icon(Icons.navigate_next),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Center(child: Text('No posts available'));
                                  }
                                } else {
                                  return Center(child: CircularProgressIndicator());
                                }
                              },
                            ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('This Week\'s Highlights', style: TextStyle(fontFamily: 'Ubuntu', fontSize: 17)),
                            // RichText(
                            //   text: TextSpan(
                            //     text: 'This ',
                            //     style: TextStyle(
                            //       fontSize: 17,
                            //       fontFamily: 'Ubuntu',
                            //     ),
                            //     children: [
                            //       TextSpan(
                            //         text: 'Week\'s Highlights',
                            //         style: TextStyle(
                            //           fontSize: 17,
                            //           fontFamily: 'Ubuntu',
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => viewAllProduct()),
                                );
                              },
                              child: Text('View All'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),
                      SizedBox(
                        width: 350.h, // Set the width of the SizedBox
                        height: 300.w,
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance.collection('sellers').snapshots(),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Unauthorized User'));
                            } else if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              var sellers = snapshot.data.docs;
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: sellers.map<Widget>((seller) {

                                    String storename = seller['storeName'];
                                    String phoneNum = seller['phoneNum'];
                                    String email = seller['email'];

                                    return FutureBuilder(
                                      future: FirebaseFirestore.instance
                                          .collection('sellers')
                                          .doc(seller.id) // Seller ID
                                          .collection('active product')
                                          // .orderBy('time', descending: true)
                                          // .limit(1)
                                          .get(),
                                      builder: (context, AsyncSnapshot productSnapshot) {
                                        if (productSnapshot.hasError) {
                                          return Text('Error: ${productSnapshot.error}');
                                        } else if (!productSnapshot.hasData) {
                                          return SizedBox();
                                        } else {
                                          var products = productSnapshot.data.docs;
                                          return Row(
                                            children: products.map<Widget>((product) {
                                              String title = product['title'];
                                              String description = product['description'];
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
                                                      description: description,
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
                                                  margin: EdgeInsets.all(10),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 100.h,
                                                        height: 100.w,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[300],
                                                          border: Border.all(color: Colors.black.withOpacity(0.2)),
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
                                                      SizedBox(height: 10.w),
                                                      Flexible(
                                                        child: Container(
                                                          width: 100.h,
                                                          height: 80.w,
                                                          child: Text('${title}',
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              // fontWeight: FontWeight.bold,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 3,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 5.h),
                                                      RichText(
                                                        text: TextSpan(
                                                          text: '\R\s ',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            // fontWeight: FontWeight.bold,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text: '$saleprice  ',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: '$compareprice',
                                                              style: TextStyle(
                                                                decoration: TextDecoration.lineThrough,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // Text('\R\s $saleprice',
                                                      //     style:
                                                      //     TextStyle(fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 10.h),
                                                      Container(
                                                        height: 40.h,
                                                        width: 100.w,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.black,
                                                            width: 1.0,
                                                          ),
                                                          color: Colors.transparent,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            // cartCount++;
                                                            // print('Item in Cart : ${cartCount}');
                                                            addToCart(title, saleprice, compareprice, description, storename, phoneNum, email, imageUrl1, imageUrl2, imageUrl3, imageUrl4);
                                                          },
                                                          child: Center(
                                                            child: Text(
                                                              'ADD TO CART',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 5.h),
                                                      Container(
                                                        height: 40.h,
                                                        width: 100.w,
                                                        decoration: BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => productListScreen(
                                                                title: title,
                                                                description: description,
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
                                                                fontSize: 10,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
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
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('NEWST!', style: TextStyle(fontFamily: 'Ubuntu', fontSize: 18)),
                              // Icon(Icons.more_vert),
                              Container(
                                height: 35.h,
                                width: 35.w,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: IconButton(
                                    onPressed: () {
                                      // Navigator.of(context).pop();
                                    },
                                    icon: Icon(Icons.more_vert),
                                    iconSize: 15,
                                    color: Colors.white
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Container(
                        width: 350.h,
                        height: 200.w,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/popularProduct.jpg'),
                              fit: BoxFit.fill
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 60.h,
                                width: 150.w,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Coming Soon',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black.withOpacity(0.8),
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recommended for You', style: TextStyle(fontFamily: 'Ubuntu', fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      RecommendedSection(buyerId: buyerId),
                      SizedBox(height: 45.h),
                      Center(child: Text('Stitch Hub ® 2024 - All Rights Reserved.')),
                    ],
                  ),
                ),
              ),
              if (_searchResults.isNotEmpty || _focusNode.hasFocus)
                Positioned(
                    top: 5,
                    left: 20,
                    right: 20,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 300.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView(
                        children: [
                          if (_searchResults.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _searchResults.map((result) {
                                return GestureDetector(
                                  onTap: () {
                                    searchHistory(
                                      result.title,
                                      result.price,
                                      result.storeName,
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => productListScreen(
                                          title: result.title,
                                          description: result.description,
                                          saleprice: result.price,
                                          compareprice: result.comparePrice,
                                          storeName: result.storeName,
                                          phoneNum: result.phoneNum,
                                          email: result.email,
                                          imageURL1: result.imageUrl,
                                          imageURL2: result.imageURL2,
                                          imageURL3: result.imageURL3,
                                          imageURL4: result.imageURL4,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    title: Text(result.title),
                                    subtitle: Text('Rs ${result.price}'),
                                    leading: result.imageUrl.isNotEmpty
                                        ? Image.network(result.imageUrl)
                                        : Container(width: 50, height: 50, color: Colors.grey),
                                  ),
                                );
                              }).toList(),
                            ),
                          if (_focusNode.hasFocus && _searchResults.isEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Recent Search', style: TextStyle(fontFamily: 'Ubuntu', fontSize: 17, fontWeight: FontWeight.bold)),
                                ),
                                SingleChildScrollView(
                                  child: Column(
                                    children: _searchHistory.map((history) {
                                      return ListTile(
                                        leading: Icon(Icons.history, color: Colors.grey),
                                        title: Text(history),
                                        onTap: () {
                                          print('Tapped on search history: $history'); // Debug statement
                                          setState(() {
                                            searchController.text = history;
                                          });
                                          searchProducts(history);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Recommended', style: TextStyle(fontFamily: 'Ubuntu', fontSize: 17, fontWeight: FontWeight.bold)),
                                ),
                                SingleChildScrollView(
                                  child: Column(
                                    children: _recommendedSearches.map((recommendation) {
                                      return ListTile(
                                        title: Text(recommendation),
                                        onTap: () {
                                          print('Tapped on recommended: $recommendation'); // Debug statement
                                          setState(() {
                                            searchController.text = recommendation;
                                          });
                                          searchProducts(recommendation);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String category, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => categoryScreen(category: category)),
        );
      },
      child: Container(
        margin: EdgeInsets.all(10),
        width: 100.w,
        child: Column(
          children: [
            Container(
              width: 100.h,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(color: Colors.black.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  image: imageUrl.startsWith('assets')
                      ? AssetImage(imageUrl)
                      : NetworkImage(imageUrl) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              height: 60.h,
              width: 100.w,
              child: Text(
                category,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

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
                  child: Text('Messages', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
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
  late String _fullName = '';
  late String _email = '';
  late String _userName = '';
  // String _profileImageUrl = '';
  // File? _buyerImageFile;
  // final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _buyerImage;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);

    try {
      if(img != null) {

        User? user = FirebaseAuth.instance.currentUser;

        if(user == null) {
          print('User is not authorized');
        } else {
          String buyerId = user.uid;

          Reference ref = FirebaseStorage.instance.ref().child('user_images/${buyerId}/buyer_image.jpg');
          UploadTask uploadTask = ref.putData(img);

          uploadTask.then((TaskSnapshot snapshot) {
            snapshot.ref.getDownloadURL().then((downloadUrl) {
              FirebaseFirestore.instance.collection('buyers').doc(buyerId).update({
                'buyerImageURL': downloadUrl,
              }).then((value) {
                setState(() {
                  _buyerImage = img;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Image Successfully Uploaded!'),
                    ));
              }).catchError((error) {
                print("Failed to update user document: $error");
              });
            });
          });
        }
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
  //
  //     // if(pickedFile != null) {
  //     //   final imageFile = File(pickedFile.path);
  //     //   setState(() {
  //     //     _buyerImageFile = imageFile;
  //     //   });
  //     // } else {
  //     //   ScaffoldMessenger.of(context).showSnackBar(
  //     //       SnackBar(
  //     //         content: Text('Please select an image file.'),
  //     //       ));
  //     // }
  //
  //     // if (pickedFile != null) {
  //     //   final File imageFile = File(pickedFile.path);
  //     //   final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
  //     //   if (decodedImage != null) {
  //     //     setState(() {
  //     //       _buyerImageFile = imageFile;
  //     //     });
  //     //   } else {
  //     //     ScaffoldMessenger.of(context).showSnackBar(
  //     //         SnackBar(
  //     //             content: Text('Please select an image file.'),
  //     //         ));
  //     //   }
  //     // }
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
  //   //     _buyerImageFile = File(pickedFile.path);
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
          .collection('buyers').doc(email).get();

      setState(() {
        _fullName = userData['fullName'];
        _userName = userData['username'];
        _email = userData['email'];
      });
    }
  }

  // Future<DocumentSnapshot<Map<String, dynamic>>?> _fetchUserData() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     String? buyerId = user.email;
  //     DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance.collection('buyers').doc(buyerId).get();
  //     return userData;
  //   } else {
  //     return null;
  //   }
  // }

  // Future<void> _fetchUserData() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     String buyeId = user.uid;
  //
  //     try {
  //       DocumentSnapshot userData = await FirebaseFirestore.instance
  //           .collection('buyers').doc(buyeId).get();
  //
  //       if(userData.exists) {
  //         Map<String, dynamic>? data = userData.data() as Map<String, dynamic>?;
  //
  //         if(data != null) {
  //           _fullName = data['fullName'];
  //         } else {
  //           print('Fullname Field not exists');
  //         }
  //       } else {
  //         print('Document does not exists');
  //       }
  //     } catch (e) {
  //       print('Error fetching user data: $e');
  //     }
  //   } else {
  //     print('User is not authenticated');
  //   }
  // }

  Future<void> _signout() async {
    try{
      await clearCredentials();
      await FirebaseAuth.instance.signOut();
      Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> clearCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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
                                    _buyerImage != null ?
                                        CircleAvatar(
                                          radius: 35,
                                          backgroundImage: MemoryImage(_buyerImage!),
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
                                      left: 38,
                                    )
                                  ],
                                ),
                                SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                                    //     future: _fetchUserData(),
                                    //     builder: (context, snapshot) {
                                    //       if (snapshot.hasError) {
                                    //         return Text('Error: ${snapshot.error}');
                                    //       } else {
                                    //         Map<String, dynamic>? data = snapshot.data!.data();
                                    //         if (data != null) {
                                    //           String fullName = data['username'];
                                    //           // Set other user data fields as needed
                                    //           return Text('$fullName');
                                    //         } else {
                                    //           return Text('Full Name not found');
                                    //         }
                                    //       }
                                    //     },
                                    // ),
                                    Text('$_fullName', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
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
                                        Text('+92 311 5292326'),
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
                Tab(text: 'Bidding'),
                Tab(text: 'Promos'),
                Tab(text: 'Sales'),
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
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('buyers')
                      .doc(userId)
                      .collection('Bid Post')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      var bidPosts = snapshot.data?.docs;
                      if (bidPosts != null && bidPosts.isNotEmpty) {
                        return SingleChildScrollView(
                          child: Column(
                            children: bidPosts?.map((bidPost) {
                              String description = bidPost['Description'];
                              String imageUrl = bidPost['Image'] ?? '';
                              String bidAmount = bidPost['Bid Amount'] ?? '500';
                              String duration = bidPost['Duration'] ?? '5';
                              String storeEmail = bidPost['Store Email'] ?? '';
                              String storeName = bidPost['Store Name'] ?? '';
                              String storeUsername = bidPost['Store Username'] ?? '';
                              String buyerEmail = bidPost['Buyer Email'] ?? '';
                              String buyerName = bidPost['Buyer Name'] ?? '';
                              String buyerUsername = bidPost['Buyer Username'] ?? '';

                              String status = 'Pending';
                              // var timestamp = order['dateTime'] as Timestamp;
                              // var date = timestamp.toDate();
                              // var dateTime = DateFormat.yMMMMd().format(date);
                              String bidId = bidPost.id;

                              return Container(
                                height: 210,
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
                                        Text('Ref No: 6637673'),
                                        Text('$storeName'),
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
                                                        Text('Bid Amount: '),
                                                        Text('RS $bidAmount', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 150,
                                                    height: 50,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('Duration: '),
                                                        Text('$duration', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                                    child: Text('$description',
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
                                          width: 320,
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5)),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {

                                                  },
                                                  child: Center(
                                                    child: Container(
                                                      height: 30,
                                                      width: 140,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors.black,
                                                          width: 1.0,
                                                        ),
                                                        color: Colors.transparent,
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: Center(child: Text('Accept',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 15,
                                                        ),
                                                      )),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {

                                                  },
                                                  child: Center(
                                                    child: Container(
                                                      height: 30,
                                                      width: 140,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius: BorderRadius.circular(5),
                                                        // border: Border(right: BorderSide(width: 4)),
                                                      ),
                                                      child: Center(child: Text('Reject',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                        ),
                                                      )),
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                                                            currentUserId:
                                                            currentUserId)));

                                          },
                                          icon: Icon(Icons.insert_comment_rounded),
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
                          child: Text('No Bidding Notification'),
                        );
                      }
                    }
                  }
              ),
            ),
            Container(
              child: Center(
                child: Text('No Promos Notification'),
              ),
            ),
            Container(
              child: Center(
                child: Text('No Sales Notification'),
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


class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {

  TextEditingController _descriptionController = TextEditingController();
  // List<String> _images = [];
  late String _fullName = '';
  late String _username = '';

  final ImagePicker _imagePicker = ImagePicker();
  final Location _location = Location();
  File? _imageFile;
  File? _videoFile;
  LocationData? _userLocation;
  File? _buyerImageFile;

  Future<String> uploadImage(File imageFile) async {
    try {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImage = referenceRoot.child('postImages');
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

  Future<void> addPost() async {

    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (user == null) {
      print('User is not logged in.');
      return;
    }

    String? userId = user.email;
    String? imageUrl = _imageFile != null ? await uploadImage(_imageFile!) : null;

    try {
      DocumentReference userDocRef = firestore.collection('buyers').doc(userId);
      DocumentSnapshot userDocSnapshot = await userDocRef.get();
      print('${userId}');
      if (!userDocSnapshot.exists) {
        print('User document does not exist.');
        return;
      } else {
        DocumentReference postRef = await userDocRef.collection('posts').add({
          'description': _descriptionController.text.trim(),
          'imageUrl': imageUrl,
          'time': FieldValue.serverTimestamp(),
        });
        print('User ID: ${userDocRef.id}');
        print('Post added with ID: ${postRef.id}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Post is successfully created!'),
            ));
      }
    } catch (e) {
      print('Error adding post: $e');
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectVideo() async {
    final pickedFile = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _getLocation() async {
    final locationData = await _location.getLocation();
    setState(() {
      _userLocation = locationData;
    });
  }

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
          .collection('buyers').doc(email).get();


      if (mounted) {
        setState(() {
          _fullName = userData['fullName'];
          _username = userData['username'];
        });
      }
    }
  }

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
                  child: Text('Create Post',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Container(
                  height: 40,
                  width: 80,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(child: TextButton(
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
                        addPost();
                      },
                      child: Text('Post', style: TextStyle(color: Colors.white, fontSize: 18)))),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              SizedBox(height: 10),
              Center(
                child: Container(
                  height: 370,
                  width: 380,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.transparent,
                      width: 1.0,
                    )
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Container(
                        height: 70,
                        width: 380,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          // borderRadius: BorderRadius.circular(100),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Row(
                            children: [
                              // Container(
                              //   height: 50,
                              //   width: 50,
                              //   decoration: BoxDecoration(
                              //     color: Colors.black,
                              //     borderRadius: BorderRadius.circular(100),
                              //   ),
                              //   child: Icon(Icons.person, color: Colors.white),
                              // ),
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: _buyerImageFile != null ? FileImage(_buyerImageFile!) : null,
                                child: _buyerImageFile == null
                                    ? Icon(
                                  Icons.account_circle,
                                  size: 60,
                                  color: Colors.grey,
                                ) : null,
                              ),
                              SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$_fullName', style: TextStyle(color: Colors.black, fontSize: 18)),
                                    SizedBox(height: 4),
                                    Text('$_username', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 200,
                        width: 380,
                        child: TextFormField(
                          controller: _descriptionController,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                              hintText: 'What\'s on your mind?',
                              hintStyle: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black.withOpacity(0.7)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15, right: 15),
                          ),
                          maxLines: null,
                        ),
                      ),
                      Center(
                        child: Container(
                          height: 60,
                          width: 350,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                            // border: Border.all(
                            //   color: Colors.black,
                            //   width: 1.0,
                            // ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Add to your post', style: TextStyle(color: Colors.black)),
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          _selectImage();
                                        },
                                        icon: Icon(Icons.add_a_photo)
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          _selectVideo();
                                        },
                                        icon: Icon(Icons.video_call_sharp)
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          _getLocation();
                                        },
                                        icon: Icon(Icons.location_on_sharp)
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.person_add_alt_1)
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.more_horiz)
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),

                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 200,
                width: 200,
                child: getImageWidget(),
              ),
              // Positioned(
              //   child: GestureDetector(
              //     onTap: () {
              //       setState(() {
              //         _imageFile = null;
              //       });
              //     },
              //     child: Container(
              //       padding: EdgeInsets.all(2),
              //       color: Colors.red,
              //       child: Icon(Icons.close, color: Colors.white, size: 16),
              //     ),
              //   ),
              // ),
              // SizedBox(height: 10),
              // Center(
              //   child: Container(
              //     height: 60,
              //     width: 380,
              //     decoration: BoxDecoration(
              //       // color: Colors.black,
              //       borderRadius: BorderRadius.circular(50),
              //       border: Border.all(
              //         color: Colors.black,
              //         width: 1.0,
              //       ),
              //     ),
              //     child: Padding(
              //       padding: EdgeInsets.symmetric(horizontal: 10),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text('Add to your post', style: TextStyle(color: Colors.black)),
              //           Row(
              //             children: [
              //               IconButton(
              //                   onPressed: () {},
              //                   icon: Icon(Icons.add_a_photo)
              //               ),
              //               IconButton(
              //                   onPressed: () {},
              //                   icon: Icon(Icons.video_call_sharp)
              //               ),
              //               IconButton(
              //                   onPressed: () {},
              //                   icon: Icon(Icons.location_on_sharp)
              //               ),
              //               IconButton(
              //                   onPressed: () {},
              //                   icon: Icon(Icons.person_add_alt_1)
              //               ),
              //               IconButton(
              //                   onPressed: () {},
              //                   icon: Icon(Icons.more_horiz)
              //               ),
              //             ],
              //           )
              //         ],
              //       ),
              //     ),
              //   ),
              //
              // ),
              // SizedBox(height: 20),
              // _imageFile != null
              //     ? Image.file(_imageFile!)
              //     : Container(),
              //
              // _videoFile != null
              //     ? Text('Video Selected')
              //     : Container(),
              //
              // _userLocation != null
              //     ? Text('Location: ${_userLocation!.latitude}, ${_userLocation!.longitude}')
              //     : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getImageWidget() {

    if (kIsWeb) {
      return _imageFile != null
          ? Stack(
        children: [
          Image.network(_imageFile!.path, fit: BoxFit.cover),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _imageFile = null;
                });
              },
              child: Container(
                padding: EdgeInsets.all(2),
                color: Colors.red,
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      )
          : Container();
    } else {
      return _imageFile != null
          ? Stack(
        children: [
          Image.file(_imageFile!, fit: BoxFit.cover),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _imageFile = null;
                });
              },
              child: Container(
                padding: EdgeInsets.all(2),
                color: Colors.red,
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      )
          : Container();
    }
  }
}

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> hasHistory(String buyerId) async {
    final searchHistorySnapshot = await _firestore
        .collection('buyers')
        .doc(buyerId)
        .collection('search history')
        .get();

    final filterHistorySnapshot = await _firestore
        .collection('buyers')
        .doc(buyerId)
        .collection('filter history')
        .get();

    return searchHistorySnapshot.docs.isNotEmpty || filterHistorySnapshot.docs.isNotEmpty;
  }

  Future<List<Product>> fetchRecommendedProducts(String buyerId) async {
    List<Product> recommendedProducts = [];
    Set<Product> uniqueProducts = {};

    final searchHistorySnapshot = await _firestore
        .collection('buyers')
        .doc(buyerId)
        .collection('search history')
        .get();

    for (var doc in searchHistorySnapshot.docs) {
      String title = doc['title'];

      final sellerSnapshot = await _firestore.collection('sellers').get();
      for (var sellerDoc in sellerSnapshot.docs) {
        String storeName = sellerDoc['storeName'] ?? '';
        String phoneNum = sellerDoc['phoneNum'] ?? '';
        String email = sellerDoc['email'] ?? '';

        final productSnapshot = await _firestore
            .collection('sellers')
            .doc(sellerDoc.id)
            .collection('active product')
            .where('title', isEqualTo: title)
            .get();

        for (var productDoc in productSnapshot.docs) {
          uniqueProducts.add(
              Product.fromFirestore(productDoc, storeName, phoneNum, email));
        }
      }
    }

    final filterHistorySnapshot = await _firestore
        .collection('buyers')
        .doc(buyerId)
        .collection('filter history')
        .get();

    for (var doc in filterHistorySnapshot.docs) {
      String category = doc['category'];
      int minPrice = doc['minimum price'];
      int maxPrice = doc['maximum price'];

      final sellerSnapshot = await _firestore.collection('sellers').get();
      for (var sellerDoc in sellerSnapshot.docs) {
        String storeName = sellerDoc['storeName'] ?? '';
        String phoneNum = sellerDoc['phoneNum'] ?? '';
        String email = sellerDoc['email'] ?? '';

        final productSnapshot = await _firestore
            .collection('sellers')
            .doc(sellerDoc.id)
            .collection('active product')
            .where('category', isEqualTo: category)
            .where('price', isGreaterThanOrEqualTo: minPrice)
            .where('price', isLessThanOrEqualTo: maxPrice)
            .get();

        for (var productDoc in productSnapshot.docs) {
          uniqueProducts.add(Product.fromFirestore(productDoc, storeName, phoneNum, email));
        }
      }
    }
    recommendedProducts.addAll(uniqueProducts);
    return recommendedProducts;
  }

  Future<List<Product>> fetchAllProducts() async {
    List<Product> allProducts = [];

    final sellerSnapshot = await _firestore.collection('sellers').get();
    for (var sellerDoc in sellerSnapshot.docs) {
      String storeName = sellerDoc['storeName'] ?? '';
      String phoneNum = sellerDoc['phoneNum'] ?? '';
      String email = sellerDoc['email'] ?? '';

      final productSnapshot = await _firestore
          .collection('sellers')
          .doc(sellerDoc.id)
          .collection('active product')
          .get();

      for (var productDoc in productSnapshot.docs) {
        allProducts.add(Product.fromFirestore(productDoc, storeName, phoneNum, email));
      }
    }
    return allProducts;
  }
}

class RecommendedSection extends StatefulWidget {
  final String buyerId;

  RecommendedSection({required this.buyerId});

  @override
  _RecommendedSectionState createState() => _RecommendedSectionState();
}

class _RecommendedSectionState extends State<RecommendedSection> {
  final ProductService _productService = ProductService();
  List<Product> _recommendedProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendedProducts();
  }

  Future<void> _loadRecommendedProducts() async {
    bool hasHistory = await _productService.hasHistory(widget.buyerId);

    List<Product> products;
    if (hasHistory) {
      products = await _productService.fetchRecommendedProducts(widget.buyerId);
    } else {
      products = await _productService.fetchAllProducts();
    }

    setState(() {
      _recommendedProducts = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _recommendedProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65.h,
          ),
          itemBuilder: (context, index) {
            final product = _recommendedProducts[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => productListScreen(
                      title: product.title,
                      description: product.description,
                      saleprice: product.price,
                      compareprice: product.comparePrice,
                      storeName: product.storeName,
                      phoneNum: product.phoneNum,
                      email: product.email,
                      imageURL1: product.imageUrl,
                      imageURL2: product.imageURL2,
                      imageURL3: product.imageURL3,
                      imageURL4: product.imageURL4,
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(10),
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.black,
                //     width: 1.0,
                //   ),
                //   borderRadius: BorderRadius.circular(5),
                // ),
                child: Column(
                  children: [
                    SizedBox(height: 5.h),
                    Container(
                      width: 100.h,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.black.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(product.imageUrl, fit: BoxFit.cover)
                          : DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/product1.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Flexible(
                      child: Container(
                        width: 100.h,
                        height: 100.w,
                        child: Text(
                          product.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            // fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    RichText(
                      text: TextSpan(
                        text: '\R\s ',
                        style: TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '${product.price}  ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '${product.comparePrice}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      height: 40.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () {
                          // add to cart logic here
                        },
                        child: Center(
                          child: Text(
                            'ADD TO CART',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      height: 40.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => productListScreen(
                                title: product.title,
                                description: product.description,
                                saleprice: product.price,
                                compareprice: product.comparePrice,
                                storeName: product.storeName,
                                phoneNum: product.phoneNum,
                                email: product.email,
                                imageURL1: product.imageUrl,
                                imageURL2: product.imageURL2,
                                imageURL3: product.imageURL3,
                                imageURL4: product.imageURL4,
                              ),
                            ),
                          );
                        },
                        child: Center(
                          child: Text(
                            'BUY NOW',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            );
          },
    );
  }
}
