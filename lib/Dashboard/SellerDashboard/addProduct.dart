import 'dart:io';
import 'dart:io' show Platform;
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/productListed.dart';

class addProduct extends StatefulWidget {
  const addProduct({super.key});

  @override
  State<addProduct> createState() => _addProductState();
}

class _addProductState extends State<addProduct> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  List<String> _recommendedSearches = [];
  bool _isLoading = false;

  String _productTitle = '';
  String _productCost = '';
  String _compareCost = '';
  String _productStock = '';
  String _productDescription = '';
  String productSKU = '';

  List<String> selectedColors = [];
  List<String> availableColors = ['Black', 'Brown', 'White', 'Off White', 'Maroon', 'Red', 'Green', 'Blue', 'Yellow', 'Purple'];

  bool sizeS = false;
  bool sizeM = false;
  bool sizeL = false;
  bool sizeXL = false;

  final int maxTitleWords = 20;
  final int maxDescriptionWords = 100;

  // List<File?> _images = [];
  File? _image1;
  File? _image2;
  File? _image3;
  File? _image4;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _productCostController = TextEditingController();
  final TextEditingController _compareCostController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  // List<String> categories = ['Pant', 'Shirt', 'Kurta', 'Coat', '3 Piece', 'Kameez Shalwar'];
  int wordCount = 0;
  String _selectedCategory = '';
  // String? _selectedCategory;
  double containerHeight = 150;
  double? _predictedPrice;

  Future<double> getPredictedPrice(String category, String title) async {

    var url = Uri.parse('http://172.16.20.32:5000/predict_price');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'category': category, 'title': title}),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return jsonResponse['predicted_price'];
    } else {
      throw Exception('Failed to predict price');
    }
  }

  double roundToNearestHundred(double value) {
    return (value / 100).round() * 100;
  }

  void _getPredictedPrice() async {
    String category = _categoryController.text;
    String title = _titleController.text;

    double price = await getPredictedPrice(category, title);
    setState(() {
      _predictedPrice = roundToNearestHundred(price);
      _productCostController.text = _predictedPrice!.toStringAsFixed(0);
      print("${_predictedPrice}");
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });
    List<String> categories = await fetchUniqueCategories();

    setState(() {
      _recommendedSearches = categories;
      _isLoading = false;
    });
  }

  Future<List<String>> fetchUniqueCategories() async {
    Set<String> categories = {};
    QuerySnapshot sellersSnapshot = await FirebaseFirestore.instance.collection('sellers').get();

    for (var sellerDoc in sellersSnapshot.docs) {
      QuerySnapshot productsSnapshot = await sellerDoc.reference.collection('active product').get();
      for (var productDoc in productsSnapshot.docs) {
        String category = productDoc['category'];
        categories.add(category);
      }
    }
    return categories.toList();
  }

  void _checkTitleLimit(String value) {
    if (value.isNotEmpty) {
      List<String> words = value.split(' ');
      if (words.length >= maxTitleWords) {
        setState(() {
          _titleController.text = words.sublist(0, maxTitleWords).join(' ');
        });
      }
      else {
        setState(() {
          _productTitle = value;
          wordCount = _countWords(value);
        });
      }
    }
  }

  void _checkDescriptionLimit(String value) {
    if (value.isNotEmpty) {
      List<String> words = value.split(' ');
      if (words.length > maxDescriptionWords) {
        setState(() {
          _productDescription = words.sublist(0, maxDescriptionWords).join(' ');
        });
      }
      else{
        setState(() {
          _productDescription = value;
          wordCount = _countWords(value);
        });
      }
    }
  }

  void _selectImage(int imageNumber) async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if(pickedImage != null) {
      setState(() {
        // _images[index] = File(pickedImage.path);
        switch (imageNumber) {
          case 1:
            _image1 = File(pickedImage.path);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Image 1 Successfully Uploaded!'),
                ));
            break;
          case 2:
            _image2 = File(pickedImage.path);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Image 2 Successfully Uploaded!'),
                ));
            break;
          case 3:
            _image3 = File(pickedImage.path);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Image 3 Successfully Uploaded!'),
                ));
            break;
          case 4:
            _image4 = File(pickedImage.path);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Image 4 Successfully Uploaded!'),
                ));
            break;
        }
      });
    }
  }

  Future<String> uploadImage(File imageFile) async {
    String imageURL;
    try {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('productIimages/$imageName');
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

  void addProduct() async {
    if (_image1 == null) {
      print('Please select atleast one image!');
      alertMessage.showAlert(context, 'Error', 'Please select atleast one image!');
      return;
    }

    User? user = _auth.currentUser;

    if (user == null) {
      print('User is not logged in.');
      return;
    }

    String? userId = user.email;

    String? imageUrl1 = _image1 != null ? await uploadImage(_image1!) : null;
    String? imageUrl2 = _image2 != null ? await uploadImage(_image2!) : null;
    String? imageUrl3 = _image3 != null ? await uploadImage(_image3!) : null;
    String? imageUrl4 = _image4 != null ? await uploadImage(_image4!) : null;

    try {
      DocumentReference userDocRef = await _firestore.collection('sellers').doc(userId);
      DocumentSnapshot userDocSnapshot = await userDocRef.get();
      print('${userId}');
      if (!userDocSnapshot.exists) {
        print('User document does not exist.');
        return;
      } else {
        DocumentReference postRef = await userDocRef.collection('active product').add({
          'title': _titleController.text.trim(),
          'productSKU': productSKU,
          'category': _selectedCategory,
          'imageUrl1': imageUrl1,
          'imageUrl2': imageUrl2,
          'imageUrl3': imageUrl3,
          'imageUrl4': imageUrl4,
          'description': _productDescription,
          'saleCost': _productCost,
          'compareCost': _compareCost,
          'stock': _productStock,
          'colors': selectedColors,
          'time': FieldValue.serverTimestamp(),
        });
        print('User ID: ${userDocRef.id}');
        print('Post added with ID: ${postRef.id}');

        Navigator.push(context, MaterialPageRoute(builder: (context) => productSuccessfullyListed()));

      }
    } catch (e) {
      print('Error adding product: $e');
      alertMessage.showAlert(context, 'Error', 'Error adding product: $e');
    }
  }

  Future<void> draftProduct() async {
    if (_image1 == null) {
      print('Please select atleast one image!');
      alertMessage.showAlert(context, 'Error', 'Please select atleast one image!');
      return;
    }

    User? user = _auth.currentUser;

    if (user == null) {
      print('User is not logged in.');
      return;
    }

    String? userId = user.email;

    String? imageUrl1 = _image1 != null ? await uploadImage(_image1!) : null;
    String? imageUrl2 = _image2 != null ? await uploadImage(_image2!) : null;
    String? imageUrl3 = _image3 != null ? await uploadImage(_image3!) : null;
    String? imageUrl4 = _image4 != null ? await uploadImage(_image4!) : null;

    try {
      DocumentReference userDocRef = await _firestore.collection('sellers').doc(userId);
      DocumentSnapshot userDocSnapshot = await userDocRef.get();
      print('${userId}');
      if (!userDocSnapshot.exists) {
        print('User document does not exist.');
        return;
      } else {
        DocumentReference postRef = await userDocRef.collection('draft product').add({
          'title': _titleController.text.trim(),
          'productSKU': productSKU,
          'category': _selectedCategory,
          'imageUrl1': imageUrl1,
          'imageUrl2': imageUrl2,
          'imageUrl3': imageUrl3,
          'imageUrl4': imageUrl4,
          'description': _productDescription,
          'saleCost': _productCost,
          'compareCost': _compareCost,
          'stock': _productStock,
          'colors': selectedColors,
          'time': FieldValue.serverTimestamp(),
        });
        print('User ID: ${userDocRef.id}');
        print('Post added with ID: ${postRef.id}');
        alertMessage.showAlert(context, 'Success', 'Product successfully drafted!');
      }
    } catch (e) {
      print('Error adding product: $e');
      alertMessage.showAlert(context, 'Error', 'Error adding product: $e');
    }
  }

  int _countWords(String text) {
    if (text.isEmpty) return 0;
    return text.trim().split(' ').where((element) => element.isNotEmpty).length;
  }

  void _updateContainerHeight() {
    setState(() {
      containerHeight = _calculateTextHeight(_descriptionController.text) + 50; // Adjust container height based on text input height
    });
  }

  double _calculateTextHeight(String text) {
    final textStyle = TextStyle(fontSize: 16); // Set the font size
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(text: textSpan, maxLines: null, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: MediaQuery.of(context).size.width - 40); // Adjust width as needed
    return textPainter.height;
  }


  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_updateContainerHeight);
    _loadCategories();
    _categoryController.addListener(_getPredictedPrice);
    // _titleController.addListener(_getPredictedPrice);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    // _titleController.dispose();
    _descriptionController.removeListener(_updateContainerHeight);
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double containerHeight = 150 + (selectedColors.length * 20);

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
                  child: Text('Add Product',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500)),
                ),
                TextButton(
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
                      draftProduct();
                    },
                    child: Text('Save Draft')
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
                    child: Row(
                      children: [
                        Text(
                          'Product Detail',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Text('$wordCount/20 words'),
                      ],
                    ),
                  ),
                  Container(
                    height: 310,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              hintText: 'Enter Title in English',
                              contentPadding: EdgeInsets.only(top: 20, left: 10),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                            ),
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return "Product SKU is required";
                              }
                              return null;
                            }),
                            onChanged: (value) {
                              setState(() {
                                _productTitle = value;
                                wordCount = _countWords(value);
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: TextFormField(
                            controller: _skuController,
                            decoration: InputDecoration(
                              labelText: 'SKU',
                              hintText: 'Enter Product Code',
                              contentPadding: EdgeInsets.only(top: 20, left: 10),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                            ),
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return "Product SKU is required";
                              }
                              return null;
                            }),
                            onChanged: (value) {
                              setState(() {
                                productSKU = value;
                              });
                            },
                          ),
                        ),
                        // Padding(
                        //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        //   child: Container(
                        //     height: 50,
                        //     width: 380,
                        //     child: DropdownButtonFormField<String>(
                        //       value: _selectedCategory,
                        //       onChanged: (String? newValue) {
                        //         setState(() {
                        //           _selectedCategory = newValue;
                        //         });
                        //       },
                        //       items: categories.map((String category) {
                        //         return DropdownMenuItem<String>(
                        //           value: category,
                        //           child: Text(category),
                        //         );
                        //       }).toList(),
                        //       decoration: InputDecoration(
                        //         hintText: 'Category',
                        //         focusedBorder: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(10),
                        //         ),
                        //         enabledBorder: OutlineInputBorder(
                        //             borderSide: BorderSide(color: Colors.grey),
                        //             borderRadius: BorderRadius.circular(10)
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: TextFormField(
                            controller: _categoryController,
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: Container(
                                          height: 400, //
                                          color: Colors.white,// Adjust height as needed
                                          child: _isLoading
                                              ? Center(child: CircularProgressIndicator())
                                              : Stack(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Select Category',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: SingleChildScrollView(
                                                            child: Column(
                                                              children: _recommendedSearches.map((recommendation) {
                                                                return ListTile(
                                                                  title: Text(recommendation),
                                                                  onTap: () {
                                                                    print('Tapped on recommended: $recommendation');
                                                                    setState(() {
                                                                      _categoryController.text = recommendation;
                                                                    });
                                                                    Navigator.pop(context);
                                                                  },
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 5,
                                                    right: 5,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                          )
                                      ),
                                    );
                                  }
                              );
                            },
                            decoration: InputDecoration(
                              labelText: 'Category',
                              hintText: 'Enter Category',
                              contentPadding: EdgeInsets.only(top: 20, left: 10),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                            ),
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return "Product Category is required";
                              }
                              return null;
                            }),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                          ),
                        ),
                        // ElevatedButton(
                        //   onPressed: _getPredictedPrice,
                        //   child: Text('Get'),
                        // ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Text(
                      'Media Selection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    height: 130,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildImageContainer(_image1, 1),
                        _buildImageContainer(_image2, 2),
                        _buildImageContainer(_image3, 3),
                        _buildImageContainer(_image4, 4),
                      ],
                    ),
                  ),
                  // SizedBox(height: 5),
                  // Row(
                  //   children: [
                  //     Text('Product Title', style: TextStyle(fontSize: 20)),

                  //   ],
                  // ),
                  // SizedBox(height: 5),
                  // TextFormField(
                  //   controller: _titleController,
                  //   maxLines: null,
                  //   decoration: InputDecoration(
                  //     hintText: 'Enter Title in English',
                  //     focusedBorder: OutlineInputBorder(
                  //         borderSide: BorderSide(color: Colors.blueAccent),
                  //         borderRadius: BorderRadius.circular(0)),
                  //     enabledBorder: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(0)),
                  //   ),
                  // ),
                  // SizedBox(height: 10),
                  // Text('Product Category', style: TextStyle(fontSize: 20)),
                  // SizedBox(height: 5),
                  // Container(
                  //   height: 55,
                  //   width: 400,
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.black),
                  //     borderRadius: BorderRadius.circular(0),
                  //   ),
                  //   child: DropdownButtonFormField<String>(
                  //     value: _selectedCategory,
                  //     onChanged: (String? newValue) {
                  //       setState(() {
                  //         _selectedCategory = newValue;
                  //       });
                  //     },
                  //     items: categories.map((String category) {
                  //       return DropdownMenuItem<String>(
                  //         value: category,
                  //         child: Text(category),
                  //       );
                  //     }).toList(),
                  //     decoration: InputDecoration(
                  //       contentPadding: EdgeInsets.only(left: 10),
                  //       hintText: 'Select Category',
                  //       border: InputBorder.none,
                  //     ),
                  //   ),
                  // ),

                  // Text('Product Image', style: TextStyle(fontSize: 20)),
                  // SizedBox(height: 5),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     _buildImageContainer(_image1, 1),
                  //     _buildImageContainer(_image2, 2),
                  //     _buildImageContainer(_image3, 3),
                  //     _buildImageContainer(_image4, 4),
                  //     // GestureDetector(
                  //     //   onTap: () {
                  //     //     _selectImage(index);
                  //     //   },
                  //     //   child: Container(
                  //     //     width: 80,
                  //     //     height: 80,
                  //     //     decoration: BoxDecoration(
                  //     //       color: Colors.grey[300],
                  //     //       borderRadius: BorderRadius.circular(0),
                  //     //     ),
                  //     //     child: _images.isNotEmpty && _images[index] != null
                  //     //         ? Image.file(
                  //     //       _images[index]!,
                  //     //       fit: BoxFit.cover,
                  //     //     )
                  //     //         : Icon(
                  //     //       Icons.add,
                  //     //       size: 30,
                  //     //       color: Colors.grey,
                  //     //     ),
                  //     //   ),
                  //     // ),
                  //     // SizedBox(width: 5),
                  //     // GestureDetector(
                  //     //   onTap: () {},
                  //     //   child: Container(
                  //     //     width: 80,
                  //     //     height: 80,
                  //     //     decoration: BoxDecoration(
                  //     //       color: Colors.grey[300],
                  //     //       borderRadius: BorderRadius.circular(0),
                  //     //     ),
                  //     //     child: Icon(
                  //     //       Icons.add,
                  //     //       size: 30,
                  //     //       color: Colors.grey,
                  //     //     ),
                  //     //   ),
                  //     // ),
                  //     // SizedBox(width: 5),
                  //     // GestureDetector(
                  //     //   onTap: () {},
                  //     //   child: Container(
                  //     //     width: 80,
                  //     //     height: 80,
                  //     //     decoration: BoxDecoration(
                  //     //       color: Colors.grey[300],
                  //     //       borderRadius: BorderRadius.circular(0),
                  //     //     ),
                  //     //     child: Icon(
                  //     //       Icons.add,
                  //     //       size: 30,
                  //     //       color: Colors.grey,
                  //     //     ),
                  //     //   ),
                  //     // ),
                  //     // SizedBox(width: 5),
                  //     // GestureDetector(
                  //     //   onTap: () {},
                  //     //   child: Container(
                  //     //     width: 80,
                  //     //     height: 80,
                  //     //     decoration: BoxDecoration(
                  //     //       color: Colors.grey[300],
                  //     //       borderRadius: BorderRadius.circular(0),
                  //     //     ),
                  //     //     child: Icon(
                  //     //       Icons.add,
                  //     //       size: 30,
                  //     //       color: Colors.grey,
                  //     //     ),
                  //     //   ),
                  //     // ),
                  //   ],
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
                    child: Row(
                      children: [
                        Text(
                          'Product Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Text('$wordCount/100 words'),
                      ],
                    ),
                  ),
                  Container(
                    height: containerHeight,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.transparent),
                            ),
                            child: TextFormField(
                              controller: _descriptionController,
                              maxLines: null,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                hintText: 'Enter Description in English',
                                contentPadding: EdgeInsets.only(top: 20, left: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                              ),
                              validator: ((value) {
                                if (value == null || value.isEmpty) {
                                  return "Product Description is required";
                                }
                                return null;
                              }),
                              onChanged: (value) {
                                _productDescription = value;
                                _checkDescriptionLimit(value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Text(
                      'Color and Size',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    height: containerHeight,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: Text(
                                'Size: ',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: sizeS,
                              onChanged: (newValue) {
                                setState(() {
                                  sizeS = newValue!;
                                });
                              },
                            ),
                            Text('S'),
                            Checkbox(
                              value: sizeM,
                              onChanged: (newValue) {
                                setState(() {
                                  sizeM = newValue!;
                                });
                              },
                            ),
                            Text('M'),
                            Checkbox(
                              value: sizeL,
                              onChanged: (newValue) {
                                setState(() {
                                  sizeL = newValue!;
                                });
                              },
                            ),
                            Text('L'),
                            Checkbox(
                              value: sizeXL,
                              onChanged: (newValue) {
                                setState(() {
                                  sizeXL = newValue!;
                                });
                              },
                            ),
                            Text('XL'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: Text(
                                'Color: ',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            DropdownButton<String>(
                              value: null,
                              hint: Text('Select color'),
                              items: availableColors.map((color) {
                                return DropdownMenuItem<String>(
                                  value: color,
                                  child: Text(color),
                                );
                              }).toList(),
                              onChanged: (selectedColor) {
                                setState(() {
                                  if (selectedColor != null) {
                                    selectedColors.add(selectedColor);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          children: selectedColors.map((color) {
                            return Container(
                              margin: EdgeInsets.all(3),
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(color),
                                  SizedBox(width: 4),
                                  IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        selectedColors.remove(color);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Text(
                      'Price and Stock',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    height: 210,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                height: 100,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Container(
                                    child: TextFormField(
                                      controller: _productCostController,
                                      decoration: InputDecoration(
                                        labelText: 'Price',
                                        hintText: 'Sale Price',
                                        contentPadding: EdgeInsets.only(top: 20, left: 10),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                      ),
                                      validator: ((value) {
                                        if (value == null || value.isEmpty) {
                                          return "Product Cost is required";
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Please enter a valid price';
                                        }
                                        return null;
                                      }),
                                      onChanged: (value) {
                                        setState(() {
                                          _productCost = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Container(
                                height: 100,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Container(
                                    child: TextFormField(
                                      controller: _compareCostController,
                                      decoration: InputDecoration(
                                        labelText: 'Discount',
                                        hintText: 'Compare Price',
                                        contentPadding: EdgeInsets.only(top: 20, left: 10),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                      ),
                                      validator: ((value) {
                                        if (value == null || value.isEmpty) {
                                          return "Compare Cost is required";
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Please enter a valid price';
                                        }
                                        if (double.parse(value) <= double.parse(_productCostController.text)) {
                                          return 'Compare price must be greater than product price';
                                        }
                                        return null;
                                      }),
                                      onChanged: (value) {
                                        setState(() {
                                          _compareCost = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: TextFormField(
                            controller: _stockController,
                            decoration: InputDecoration(
                              labelText: 'Product Stock',
                              hintText: 'Enter Stock Value',
                              contentPadding: EdgeInsets.only(top: 20, left: 10),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                            ),
                            validator: ((value) {
                              if (value == null || value.isEmpty) {
                                return "Product Cost is required";
                              }
                              return null;
                            }),
                            onChanged: (value) {
                              setState(() {
                                _productStock = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  if (_predictedPrice != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Icon(Icons.info),
                          SizedBox(width: 5),
                          Text('Similar Product Price: \R\s\: ${_predictedPrice!.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: TextButton(
                                onPressed: () {

                                },
                                child: Text(
                                  'Preview',
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: TextButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
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
                                    addProduct();
                                  }
                                },
                                child: Text(
                                  'Submit',
                                  style: TextStyle(fontSize: 20, color: Colors.white),
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
          ),
        ),
      ),
    );
  }

  Widget _buildImageContainer(File? imageFile, int imageNumber) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _selectImage(imageNumber),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              border: Border.all(color: Colors.black.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(5),
            ),
            child: imageFile != null
                ? kIsWeb
                  ? Image.network(imageFile.path, fit: BoxFit.cover)
                  : Image.file(imageFile, fit: BoxFit.cover)
                : Icon(Icons.add),
          ),
        ),
        if (imageFile != null)
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  switch (imageNumber) {
                    case 1:
                      _image1 = null;
                      break;
                    case 2:
                      _image2 = null;
                      break;
                    case 3:
                      _image3 = null;
                      break;
                    case 4:
                      _image4 = null;
                      break;
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
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
