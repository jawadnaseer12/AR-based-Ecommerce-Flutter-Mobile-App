import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/shoppingCart.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/checkoutProcess.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitchhub_app/Dashboard/inAppMessaging.dart';
import 'package:intl/intl.dart';

class productListScreen extends StatefulWidget {
  final String title;
  final String category;
  final String description;
  final String productSKU;
  final int saleprice;
  final int compareprice;
  final String storeName;
  final String phoneNum;
  final String email;
  final String imageURL1;
  final String imageURL2;
  final String imageURL3;
  final String imageURL4;

  const productListScreen({
    required this.title,
    required this.category,
    required this.description,
    required this.productSKU,
    required this.saleprice,
    required this.compareprice,
    required this.storeName,
    required this.phoneNum,
    required this.email,
    required this.imageURL1,
    required this.imageURL2,
    required this.imageURL3,
    required this.imageURL4,
  });

  @override
  State<productListScreen> createState() => _productListScreenState();
}

class _productListScreenState extends State<productListScreen> {
  int cartCount = 0;
  int selectedQuantity = 1;
  String selectedSize = 'S';
  // List<int> quantities = List.generate(10, (index) => index + 1);

  TextEditingController _frontLengthController = TextEditingController();
  TextEditingController _shoulderSizeController = TextEditingController();
  TextEditingController _chestSizeController = TextEditingController();
  TextEditingController _waistSizeController = TextEditingController();
  TextEditingController _longSleeveController = TextEditingController();
  TextEditingController _collarSizeController = TextEditingController();

  String? _selectedSizeOption;
  double _containerHeight = 190;
  String newChatID = '';

  File? _scanImage;
  final picker = ImagePicker();

  Map<String, String> chartSizeImages = {
    'Waistcoat': 'assets/WaistCoatChart.jpg',
    'Dress Shirt': 'assets/FormalShirtChart.jpg',
    'Checkshirt': 'assets/CasualShirtChart.jpg',
    'T-Shirt': 'assets/CrewNeckChart.jpg',
    'Polo Shirt': 'assets/PoloShirtChart.jpg',
    '3 Piece': 'assets/SuitingChart.jpg',
    'Kameez Shalwar': 'assets/KameezShalwarChart.jpg',
    'Kurta': 'assets/KurtaPajamaChart.jpg',
  };

  String? getChartImage(String category) {

    return chartSizeImages[category];

  }

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

  Future<void> uploadAndMeasure(File image) async {
    if (image != null) {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.10.31:5000/pose_upload'));

      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }
  }

  void _pickImageAndUpload() async {
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => Center(child: CircularProgressIndicator()),
    // );

    File? image = await _selectGalleryImage();

    // Navigator.of(context).pop();

    if (image != null) {
      await uploadAndMeasure(image);
    } else {
      print("No image selected.");
    }
  }

  // Future<File?> _openCameraForTryOn() async {
  //   final imagePicker = await picker.pickImage(source: ImageSource.camera);
  //   if (imagePicker != null) {
  //
  //   }
  //   return null;
  // }

  void tryOnCloth() async{
    final imagePicker = await picker.pickImage(source: ImageSource.camera);
    if (imagePicker != null) {

    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
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
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // FloatingActionButton(
                      //   backgroundColor: Colors.red,
                      //   child: Icon(Icons.close),
                      //   onPressed: () {
                      //     Navigator.of(context).pop();
                      //   },
                      // ),
                      SizedBox(width: 10),
                      FloatingActionButton(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_forward, color: Colors.black),
                        onPressed: () {
                          _pickImageAndUpload();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('landmarkImage/$image');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _onImageSelected(File image) async {
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => Center(child: CircularProgressIndicator()),
    // );

    String? imageUrl = await _uploadImageToFirebase(image);

    // Navigator.of(context).pop();

    if (imageUrl != null) {
      _showImageDialog(imageUrl);
    }
  }

  Future<File?> _selectGalleryImage() async {
    final imagePicker = await picker.pickImage(source: ImageSource.gallery);
    if (imagePicker != null) {
      _onImageSelected(File(imagePicker.path));
      return File(imagePicker.path);
    }
    return null;
  }

  Future<File?> _selectCameraImage() async {
    final imagePicker = await picker.pickImage(source: ImageSource.camera);
    if (imagePicker != null) {
      _onImageSelected(File(imagePicker.path));
      return File(imagePicker.path);
    }
    return null;
  }

  void _showScanSizeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Container(
            height: 150,
            color: Colors.white.withOpacity(0.6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _selectCameraImage();
                    },
                    child: Container(
                      height: 50,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text("Camera",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _selectGalleryImage();
                    },
                    child: Container(
                      height: 50,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text("Gallery",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
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
  }

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

  List<String> extractKeywords(String title) {
    final stopWords = [
      'a',
      'an',
      'the',
      'and',
      'or',
      'but',
      'with',
      'on',
      'in',
      'at',
      'by',
      'for',
      'of',
      'to',
      'from'
    ];
    return title
        .split(' ')
        .where((word) => !stopWords.contains(word.toLowerCase()))
        .toList();
  }

  void addToCart(
      String title,
      String category,
      int saleprice,
      int compareprice,
      String description,
      String productSKU,
      String storename,
      String storePhoneNo,
      String storeEmail,
      String image1,
      String image2,
      String image3,
      String image4) {
    User? user = FirebaseAuth.instance.currentUser;
    String? usercartId = user?.email;

    FirebaseFirestore.instance
        .collection('buyers')
        .doc(usercartId)
        .collection('cart')
        .add({
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
      'time': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = getCurrentUserId();
    List<String> keywords = extractKeywords(widget.title);

    List<String> imageUrls = [
      widget.imageURL1,
      widget.imageURL2,
      widget.imageURL3,
      widget.imageURL4
    ];

    imageUrls = imageUrls.where((url) => url.isNotEmpty).toList();

    final int salePrice = widget.saleprice;
    final int comparePrice = widget.compareprice;
    final double discountPercentage =
        ((comparePrice - salePrice) / comparePrice) * 100;

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
                  // Container(
                  //   width: 250,
                  //   child: SingleChildScrollView(
                  //     scrollDirection: Axis.horizontal,
                  //     child: Padding(
                  //       padding: EdgeInsets.symmetric(vertical: 5),
                  //       child: Text('${widget.title}',
                  //           style: TextStyle(
                  //               color: Colors.black,
                  //               fontWeight: FontWeight.w500)),
                  //     ),
                  //   ),
                  // ),
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
                            MaterialPageRoute(
                                builder: (context) => shoppingCart()),
                          );
                        },
                        icon: SizedBox(
                          height: 25,
                          width: 25,
                          child: Icon(Icons.shopping_cart),
                        ),
                      ),
                    ),
                    if (cartCount >= 0)
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
                                  fontSize: 9),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Center(
                      child:
                      // CarouselSlider(
                      //   options: CarouselOptions(
                      //     height: 450,
                      //     aspectRatio: 1,
                      //     viewportFraction: 1.0,
                      //     enlargeCenterPage: false,
                      //     enableInfiniteScroll: false,
                      //     autoPlay: true,
                      //   ),
                      //   items: imageUrls.map((imageUrl) {
                      //     return Container(
                      //       width: 380,
                      //       decoration: BoxDecoration(
                      //         color: Colors.grey[300],
                      //         border: Border.all(
                      //             color: Colors.black.withOpacity(0.3)),
                      //       ),
                      //       child: Image.network(imageUrl, fit: BoxFit.cover),
                      //     );
                      //   }).toList(),
                      // ),
                      Container(
                        height: 380,
                        width: 380,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          border:
                              Border.all(color: Colors.black.withOpacity(0.3)),
                          // borderRadius: BorderRadius.circular(5),
                        ),
                        child: widget.imageURL1 != null
                            ? Image.network(widget.imageURL1, fit: BoxFit.cover)
                            : DecoratedBox(
                                decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/product1.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              )),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 380,
                        child: Text(
                          '${widget.title}',
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: Container(
                        width: 380,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: '\R\s\. ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '${widget.saleprice}  ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${widget.compareprice}',
                                        style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize: 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '${discountPercentage.toStringAsFixed(0)}% OFF',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                tryOnCloth();
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  // border: Border.all(
                                  //   color: Colors.black,
                                  //   width: 1.5,
                                  // ),
                                  // color: Colors.transparent,
                                  // borderRadius: BorderRadius.circular(10),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.black.withOpacity(0.5),
                                  //     spreadRadius: 2,
                                  //     blurRadius: 10,
                                  //     offset: Offset(4, 4),
                                  //   ),
                                  // ]
                                ),
                                child: Center(
                                    child: Image(
                                        image: AssetImage('assets/whiteHanger.png'), height: 45, width: 45)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Center(
                      child: Container(
                        height: 50,
                        width: 350,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5,
                          ),
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          onPressed: () {
                            addToCart(
                                widget.title,
                                widget.category,
                                widget.saleprice,
                                widget.compareprice,
                                widget.description,
                                widget.productSKU,
                                widget.storeName,
                                widget.phoneNum,
                                widget.email,
                                widget.imageURL1,
                                widget.imageURL2,
                                widget.imageURL3,
                                widget.imageURL4);
                          },
                          child: Center(
                            child: Text(
                              'ADD TO CART',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: Container(
                        height: 50,
                        width: 350,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => checkoutProcess(
                                        title: widget.title,
                                        productSKU: widget.productSKU,
                                        saleprice: widget.saleprice,
                                        compareprice: widget.compareprice,
                                        storeName: widget.storeName,
                                        email: widget.email,
                                        quantity: selectedQuantity,
                                        productSize: selectedSize,
                                        imageURL1: widget.imageURL1,
                                      )),
                            );
                          },
                          child: Center(
                            child: Text(
                              'PROCEED CHECKOUT',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quantity: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, size: 25),
                                onPressed: () {
                                  setState(() {
                                    if (selectedQuantity > 1) {
                                      selectedQuantity--;
                                    }
                                  });
                                },
                              ),
                              Container(
                                height: 50,
                                width: 50,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    '$selectedQuantity',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(width: 5),
                              IconButton(
                                icon: Icon(Icons.add, size: 25),
                                onPressed: () {
                                  setState(() {
                                    selectedQuantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Size: ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          TextButton(
                              onPressed: () {

                                String? chartImage = getChartImage(widget.category);

                                if (chartImage != null) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.white,
                                        child: Container(
                                          height: 500,
                                          child: Stack(
                                            children: [
                                              Center(
                                                child: Image.asset(
                                                  chartImage,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              Positioned(
                                                top: 20,
                                                right: 20,
                                                child: IconButton(
                                                  icon: Icon(Icons.close, color: Colors.black, size: 30),
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
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: Colors.white,
                                      child: Container(
                                        height: 500,
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Text('No Size Chart Available', style: TextStyle(color: Colors.black)),
                                            ),
                                            Positioned(
                                              top: 20,
                                              right: 20,
                                              child: IconButton(
                                                icon: Icon(Icons.close, color: Colors.black, size: 30),
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
                                }
                              },
                              child: Text('Size Chart'),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: _containerHeight,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RadioListTile<String>(
                            title: Text('Select Size'),
                            value: 'selectSize',
                            groupValue: _selectedSizeOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedSizeOption = value;
                                _containerHeight =
                                    value == 'selectSize' ? 250 : 190;
                              });
                            },
                          ),
                          Visibility(
                            visible: _selectedSizeOption == 'selectSize',
                            child: Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Row(
                                children: [
                                  Text(
                                    'Size: ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Row(
                                    children: ['S', 'M', 'L', 'XL']
                                        .map((size) => Row(
                                              children: [
                                                Radio<String>(
                                                  value: size,
                                                  groupValue: selectedSize,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedSize = value!;
                                                    });
                                                  },
                                                ),
                                                Text(size),
                                              ],
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          RadioListTile<String>(
                            title: Text('Input Size'),
                            value: 'inputSize',
                            groupValue: _selectedSizeOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedSizeOption = value;
                                _containerHeight =
                                    value == 'inputSize' ? 380 : 190;
                              });
                            },
                          ),
                          Visibility(
                            visible: _selectedSizeOption == 'inputSize',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 25),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _frontLengthController,
                                          decoration: InputDecoration(
                                            labelText: 'Front Length',
                                            suffix: Text('Inch '),
                                            // hintText: 'Enter Length',
                                            contentPadding: EdgeInsets.only(
                                                top: 20, left: 10),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.blueAccent),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: TextField(
                                          controller: _shoulderSizeController,
                                          decoration: InputDecoration(
                                            labelText: 'Shoulder',
                                            suffix: Text('Inch '),
                                            // hintText: 'Enter Length',
                                            contentPadding: EdgeInsets.only(
                                                top: 20, left: 10),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.blueAccent),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 25),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _chestSizeController,
                                          decoration: InputDecoration(
                                            labelText: 'Chest',
                                            suffix: Text('Inch '),
                                            // hintText: 'Enter Length',
                                            contentPadding: EdgeInsets.only(
                                                top: 20, left: 10),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.blueAccent),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: TextField(
                                          controller: _waistSizeController,
                                          decoration: InputDecoration(
                                            labelText: 'Waist',
                                            suffix: Text('Inch '),
                                            // hintText: 'Enter Length',
                                            contentPadding: EdgeInsets.only(
                                                top: 20, left: 10),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.blueAccent),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 25),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _longSleeveController,
                                          decoration: InputDecoration(
                                            labelText: 'Long Sleeve',
                                            suffix: Text('Inch '),
                                            // hintText: 'Enter Length',
                                            contentPadding: EdgeInsets.only(
                                                top: 20, left: 10),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.blueAccent),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: TextField(
                                          controller: _collarSizeController,
                                          decoration: InputDecoration(
                                            labelText: 'Collar',
                                            suffix: Text('Inch '),
                                            // hintText: 'Enter Length',
                                            contentPadding: EdgeInsets.only(
                                                top: 20, left: 10),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.blueAccent),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RadioListTile<String>(
                            title: Text('Scan Size'),
                            value: 'scanSize',
                            groupValue: _selectedSizeOption,
                            onChanged: (value) {
                              setState(() {
                                _selectedSizeOption = value;
                                _containerHeight =
                                    value == 'scanSize' ? 270 : 190;
                              });
                            },
                          ),
                          Visibility(
                            visible: _selectedSizeOption == 'scanSize',
                            child: Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _showScanSizeDialog();
                                          });
                                        },
                                        icon: Icon(
                                          Icons
                                              .camera_alt, // Example widget for the camera
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text('Choose full body image',
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.grey))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 5),
                          Center(
                            child: Container(
                              width: 380,
                              child: Text(
                                '${widget.description}',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: Container(
                        height: 150,
                        width: 380,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '${widget.storeName}',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Container(
                                        height: 25,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            newChatID = generateChatId();
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        chatScreen(
                                                          chatId: newChatID,
                                                          currentUserId:
                                                              widget.email,
                                                          receiverName:
                                                              widget.storeName,
                                                          isBuyer: true,
                                                        )));
                                          },
                                          child: Center(
                                            child: Text(
                                              'Chat',
                                              style: TextStyle(
                                                fontSize: 7,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Container(
                                        height: 25,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: TextButton(
                                          onPressed: () {},
                                          child: Center(
                                            child: Text(
                                              'Follow',
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
                                  SizedBox(height: 10),
                                  Text(
                                    'Email: ${widget.email}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    'Phone No: ${widget.phoneNum}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating & Review',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('sellers')
                                    .doc(widget.email)
                                    .collection('active product')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }

                                  var reviews = snapshot.data?.docs;

                                  if (reviews == null || reviews.isEmpty) {
                                    return Center(
                                        child: Text(
                                            'This product has no reviews.'));
                                  }

                                  bool hasReviews = false;

                                  return SingleChildScrollView(
                                    child: Column(
                                      children: reviews.map((review) {
                                        return StreamBuilder<
                                            QuerySnapshot<
                                                Map<String, dynamic>>>(
                                          stream: FirebaseFirestore.instance
                                              .collection('sellers')
                                              .doc(widget.email)
                                              .collection('active product')
                                              .doc(review.id)
                                              .collection('product review')
                                              .where('product title',
                                                  isEqualTo: widget.title)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'));
                                            }

                                            var productReviews =
                                                snapshot.data?.docs;

                                            if (productReviews != null &&
                                                productReviews.isNotEmpty) {
                                              hasReviews = true;
                                              return Column(
                                                children: productReviews
                                                    .map((productReview) {
                                                  var reviewData =
                                                      productReview.data();
                                                  var customerName = reviewData[
                                                      'consignee name'];
                                                  var reviewText =
                                                      reviewData['review'];

                                                  return Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8.0,
                                                            horizontal: 8.0),
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.grey
                                                              .withOpacity(
                                                                  0.5)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundImage:
                                                                  AssetImage(
                                                                      'assets/avatar.png'),
                                                              radius: 22.0,
                                                            ),
                                                            SizedBox(
                                                                width: 12.0),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    customerName,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  Image(
                                                                    image: AssetImage(
                                                                        'assets/productRating.png'),
                                                                    height: 30,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 5.0),
                                                        Text(
                                                          reviewText,
                                                          style: TextStyle(
                                                              fontSize: 14.0),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            } else {
                                              // Return an empty Container when there are no reviews for this specific product
                                              return Container();
                                            }
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Questions About This Product',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Ask Question',
                                    hintText: 'Enter your message',
                                    contentPadding:
                                        EdgeInsets.only(top: 20, left: 10),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 45),
                    Column(
                      children: [
                        Center(
                            child: Text('- Same Store Product -',
                                style: TextStyle(
                                    fontFamily: 'Ubuntu', fontSize: 18))),
                        SizedBox(height: 15),
                        SizedBox(
                          width: 350, // Set the width of the SizedBox
                          height: 200,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('sellers')
                                .doc(widget.email)
                                .snapshots(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasError) {
                                return Center(child: Text('Unauthorized User'));
                              } else if (!snapshot.hasData) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else {
                                var seller = snapshot.data;

                                String storename = seller['storeName'];
                                String phoneNum = seller['phoneNum'];
                                String email = seller['email'];

                                return FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('sellers')
                                      .doc(widget.email) // Seller ID (email)
                                      .collection('active product')
                                      .get(),
                                  builder:
                                      (context, AsyncSnapshot productSnapshot) {
                                    if (productSnapshot.hasError) {
                                      return Text(
                                          'Error: ${productSnapshot.error}');
                                    } else if (!productSnapshot.hasData) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else {
                                      var products = productSnapshot.data.docs;
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children:
                                              products.map<Widget>((product) {
                                            String title = product['title'];
                                            String category = product['category'];
                                            String description =
                                                product['description'];
                                            String productSKU =
                                                product['productSKU'];
                                            String imageUrl1 =
                                                product['imageUrl1'] ?? '';
                                            String imageUrl2 =
                                                product['imageUrl2'] ?? '';
                                            String imageUrl3 =
                                                product['imageUrl3'] ?? '';
                                            String imageUrl4 =
                                                product['imageUrl4'] ?? '';
                                            int saleprice =
                                                int.parse(product['saleCost']);
                                            int compareprice = int.parse(
                                                product['compareCost']);

                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          productListScreen(
                                                            title: title,
                                                            category: category,
                                                            description:
                                                                description,
                                                            productSKU:
                                                                productSKU,
                                                            saleprice:
                                                                saleprice,
                                                            compareprice:
                                                                compareprice,
                                                            storeName:
                                                                storename,
                                                            phoneNum: phoneNum,
                                                            email: email,
                                                            imageURL1:
                                                                imageUrl1,
                                                            imageURL2:
                                                                imageUrl2,
                                                            imageURL3:
                                                                imageUrl3,
                                                            imageURL4:
                                                                imageUrl4,
                                                          )),
                                                );
                                              },
                                              child: Container(
                                                margin: EdgeInsets.all(10),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        border: Border.all(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.3)),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: imageUrl1
                                                              .isNotEmpty
                                                          ? Image.network(
                                                              imageUrl1,
                                                              fit: BoxFit.cover)
                                                          : DecoratedBox(
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/product1.jpg'),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Flexible(
                                                      child: Container(
                                                        width: 100,
                                                        height: 100,
                                                        child: Text(
                                                          title,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            // fontWeight: FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 3,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    }
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Center(
                            child: Text('- Related Product -',
                                style: TextStyle(
                                    fontFamily: 'Ubuntu', fontSize: 18))),
                        SizedBox(height: 15),
                        SizedBox(
                          width: 350, // Set the width of the SizedBox
                          height: 200,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('sellers')
                                .snapshots(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasError) {
                                return Center(child: Text('Unauthorized User'));
                              } else if (!snapshot.hasData) {
                                return Center(
                                    child: CircularProgressIndicator());
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
                                            .get(),
                                        builder: (context,
                                            AsyncSnapshot productSnapshot) {
                                          if (productSnapshot.hasError) {
                                            return Text(
                                                'Error: ${productSnapshot.error}');
                                          } else if (!productSnapshot.hasData) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else {
                                            var products =
                                                productSnapshot.data.docs;
                                            var relatedProducts =
                                                products.where((product) {
                                              String title = product['title'];
                                              return keywords.any((keyword) =>
                                                  title.contains(keyword));
                                            }).toList();

                                            return Row(
                                              children: relatedProducts
                                                  .map<Widget>((product) {
                                                String title = product['title'];
                                                String category = product['category'];
                                                String description =
                                                    product['description'];
                                                String productSKU =
                                                    product['productSKU'];
                                                String imageUrl1 =
                                                    product['imageUrl1'] ?? '';
                                                String imageUrl2 =
                                                    product['imageUrl2'] ?? '';
                                                String imageUrl3 =
                                                    product['imageUrl3'] ?? '';
                                                String imageUrl4 =
                                                    product['imageUrl4'] ?? '';
                                                int saleprice = int.parse(
                                                    product['saleCost']);
                                                int compareprice = int.parse(
                                                    product['compareCost']);

                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              productListScreen(
                                                                title: title,
                                                                category: category,
                                                                description:
                                                                    description,
                                                                productSKU:
                                                                    productSKU,
                                                                saleprice:
                                                                    saleprice,
                                                                compareprice:
                                                                    compareprice,
                                                                storeName:
                                                                    storename,
                                                                phoneNum:
                                                                    phoneNum,
                                                                email: email,
                                                                imageURL1:
                                                                    imageUrl1,
                                                                imageURL2:
                                                                    imageUrl2,
                                                                imageURL3:
                                                                    imageUrl3,
                                                                imageURL4:
                                                                    imageUrl4,
                                                              )),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.all(10),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width: 100,
                                                          height: 100,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[300],
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.3)),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: imageUrl1 !=
                                                                  null
                                                              ? Image.network(
                                                                  imageUrl1,
                                                                  fit: BoxFit
                                                                      .cover)
                                                              : DecoratedBox(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                                    image: AssetImage(
                                                                        'assets/product1.jpg'),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                )),
                                                        ),
                                                        SizedBox(height: 10),
                                                        Flexible(
                                                          child: Container(
                                                            width: 100,
                                                            height: 100,
                                                            child: Text(
                                                              '${title}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                // fontWeight: FontWeight.bold,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 3,
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
                      ],
                    ),
                    SizedBox(height: 45),
                    Center(
                        child:
                            Text('Stitch Hub ® 2024 - All Rights Reserved.')),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
