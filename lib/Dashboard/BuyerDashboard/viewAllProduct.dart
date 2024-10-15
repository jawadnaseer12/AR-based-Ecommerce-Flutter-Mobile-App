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

class viewAllProduct extends StatefulWidget {
  const viewAllProduct({super.key});

  @override
  State<viewAllProduct> createState() => _viewAllProductState();
}

class _viewAllProductState extends State<viewAllProduct> {

  // final FirebaseAuth _auth = FirebaseAuth.instance;

  User? user = FirebaseAuth.instance.currentUser;

  String? _selectedCategory;
  List<String> _categories = ['Pant', 'Shirt', 'Kurta', 'Coat', '3 Piece', 'Kameez Shalwar', 'All'];
  bool _isLoading = false;
  List<String> listPriceRange = ['All', 'Low', 'Medium', 'High'];
  List<String> listOrder = ['Ascending', 'Descending', 'None'];
  String? _selectedPriceRange;
  int? _minPrice;
  int? _maxPrice;
  String? _selectedAlphabeticOrder;

  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Product> _searchResults = [];
  List<String> _searchHistory = [];
  List<String> _recommendedSearches = [];
  List<Product> _filterResults = [];

  bool _isFilterVisible = false;
  bool _isFilterProducts = false;

  int cartCount = 0;
  int selectedQuantity = 1;
  String selectedSize = 'S';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _focusNode.addListener(_onFocusChange);
    _fetchSearchHistory();
    _fetchCartCount();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    List<String> fetchedCategories = await fetchUniqueCategories();

    setState(() {
      _categories = fetchedCategories.isNotEmpty ? fetchedCategories : _categories;
      _isLoading = false;
    });
  }

  Future<List<String>> fetchUniqueCategories() async {
    Set<String> categoriesSet = {};
    QuerySnapshot sellersSnapshot = await FirebaseFirestore.instance.collection('sellers').get();

    for (var sellerDoc in sellersSnapshot.docs) {
      QuerySnapshot productsSnapshot = await sellerDoc.reference.collection('active product').get();
      for (var productDoc in productsSnapshot.docs) {
        String category = productDoc['category'];
        categoriesSet.add(category);
      }
    }
    return categoriesSet.toList();
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

  Future<void> searchHistory(String title, int price, String storeName) async {

    try{

      String? userSearchId = user?.email;

      if (userSearchId == null) {
        print('No user logged in');
        return;
      }
      FirebaseFirestore.instance.collection('buyers').doc(userSearchId).collection('search history').add({
        'title': title,
        'price range': price,
        'store name': storeName,
        'time': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('Error Store History: $e');
    }
  }

  void clearFilter() {
    setState(() {
      _isFilterProducts = false;
    });
  }

  Future<void> filterProduct() async {

    final List<Product> filterResults = [];
    String? userFilterId = user?.email;

    try{
      if (userFilterId == null) {
        print('No user logged in');
        return;
      }
      FirebaseFirestore.instance.collection('buyers').doc(userFilterId).collection('filter history').add({
        'minimum price': _minPrice,
        'maximum price': _maxPrice,
        'category': _selectedCategory,
        'search order': _selectedAlphabeticOrder,
        'time': FieldValue.serverTimestamp(),
      });

      QuerySnapshot sellerSnapshot = await FirebaseFirestore.instance.collection('sellers').get();
      for (var sellerDoc in sellerSnapshot.docs) {
        QuerySnapshot productSnapshot = await FirebaseFirestore.instance
            .collection('sellers')
            .doc(sellerDoc.id)
            .collection('active product')
            .get();

        for (var productDoc in productSnapshot.docs) {
          String title = productDoc['title'];
          String category = productDoc['category'];
          int price = int.parse(productDoc['saleCost']);
          String imageUrl = productDoc['imageUrl1'] ?? '';
          String description = productDoc['description'] ?? '';
          String productSKU = productDoc['productSKU'] ?? '';
          int comparePrice = int.parse(productDoc['compareCost']);
          String storeName = sellerDoc['storeName'] ?? '';
          String phoneNum = sellerDoc['phoneNum'] ?? '';
          String email = sellerDoc['email'] ?? '';
          String imageURL2 = productDoc['imageUrl2'] ?? '';
          String imageURL3 = productDoc['imageUrl3'] ?? '';
          String imageURL4 = productDoc['imageUrl4'] ?? '';

          bool matchesCategory = _selectedCategory == null || _selectedCategory == 'All' || category == _selectedCategory;
          bool matchesPrice = (_minPrice == null || price >= _minPrice!) && (_maxPrice == null || price <= _maxPrice!);

          if (matchesCategory && matchesPrice) {
            filterResults.add(Product(
              title: title,
              category: category,
              description: description,
              productSKU: productSKU,
              price: price,
              comparePrice: comparePrice,
              storeName: storeName,
              phoneNum: phoneNum,
              email: email,
              imageUrl: imageUrl,
              imageURL2: imageURL2,
              imageURL3: imageURL3,
              imageURL4: imageURL4,
            ));
          }
        }
      }

      print("Min Price: ${_minPrice}");
      print("Max Price: ${_maxPrice}");
      print("Category: ${_selectedCategory}");

      if (_selectedAlphabeticOrder != null) {
        if (_selectedAlphabeticOrder == 'Ascending') {
          filterResults.sort((a, b) => a.title.compareTo(b.title));
          print("Order: ${_selectedAlphabeticOrder}");
        } else if (_selectedAlphabeticOrder == 'Descending') {
          filterResults.sort((a, b) => b.title.compareTo(a.title));
          print("Order: ${_selectedAlphabeticOrder}");
        }
      }

      setState(() {
        _isFilterProducts = true;
        _filterResults = filterResults;
      });
    } catch (e) {
      print('Error filtering products: $e');
    }
  }

  void searchProducts(String query) {
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
            String category = productDoc['category'];
            int price = int.parse(productDoc['saleCost']);
            String imageUrl = productDoc['imageUrl1'] ?? '';
            String description = productDoc['description'] ?? '';
            String productSKU = productDoc['productSKU'] ?? '';
            int comparePrice = int.parse(productDoc['compareCost']);
            String storeName = sellerDoc['storeName'] ?? '';
            String phoneNum = sellerDoc['phoneNum'] ?? '';
            String email = sellerDoc['email'] ?? '';
            String imageURL2 = productDoc['imageUrl2'] ?? '';
            String imageURL3 = productDoc['imageUrl3'] ?? '';
            String imageURL4 = productDoc['imageUrl4'] ?? '';

            if (title.toLowerCase().contains(query.toLowerCase())) {
              searchResults.add(Product(title: title, category: category, description: description, productSKU: productSKU, price: price, comparePrice: comparePrice, storeName: storeName, phoneNum: phoneNum, email: email, imageUrl: imageUrl, imageURL2: imageURL2, imageURL3: imageURL3, imageURL4: imageURL4));
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
      'time': FieldValue.serverTimestamp(),
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 5),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : Container(
                            height: 50,
                            width: 160,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                },
                                items: _categories.map((String category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                hint: Text(' Select Category'),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            height: 50,
                            width: 160,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedAlphabeticOrder,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedAlphabeticOrder = newValue!;
                                  });
                                },
                                items: listOrder.map((String order) {
                                  return DropdownMenuItem<String>(
                                    value: order,
                                    child: Text(order),
                                  );
                                }).toList(),
                                hint: Text(' Select Order'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 50,
                            width: 130,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Min Price',
                                contentPadding: const EdgeInsets.only(top: 20, left: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5)
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _minPrice = int.tryParse(value);
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(' To ', style: TextStyle(fontFamily: 'Ubuntu', fontSize: 17)),
                          SizedBox(width: 5),
                          Container(
                            height: 50,
                            width: 130,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Max Price',
                                contentPadding: const EdgeInsets.only(top: 20, left: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5)
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _maxPrice = int.tryParse(value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            filterProduct();
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Apply'),
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
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
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
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text('All Product',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500)),
                  ),
                  Spacer(),
                  // IconButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => shoppingCart()),
                  //     );
                  //   },
                  //   icon: SizedBox(
                  //     height: 20,
                  //     width: 20,
                  //     child: Icon(Icons.shopping_cart),
                  //   ),
                  // ),
                ],
              ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                          controller: searchController,
                          focusNode: _focusNode,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                              hintText: 'Search Here',
                              hintStyle: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.7)),
                              // suffixIcon: IconButton(
                              //   onPressed: () {
                              //     setState(() {
                              //       _isFilterVisible = !_isFilterVisible;
                              //     });
                              //   },
                              //   icon: Icon(Icons.filter_list_alt),
                              // ),
                              prefixIcon: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.search),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Color(0xFF6C63FF)),
                                  borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black.withOpacity(0.7)),
                                  borderRadius: BorderRadius.circular(10)),
                              // border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15, right: 15)
                          ),
                          onChanged: (value) {
                            searchProducts(value);
                          },
                        ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showFilterDialog();
                        });
                      },
                      icon: Icon(Icons.filter_list_alt),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => viewHistory()));
                      },
                      icon: Icon(Icons.history),
                    ),
                    IconButton(
                      onPressed: () {
                        clearFilter();
                      },
                      icon: Icon(Icons.filter_alt_off),
                    ),
                  ],
                ),
              ),
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
          body: _isFilterProducts != true
            ? StreamBuilder(
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
                                  .doc(seller.id) // Seller ID
                                  .collection('active product')
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
                                                          // fontWeight: FontWeight.bold,
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
                                                        text: 'Store: ',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text: '$storename',
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
                      // if(_isFilterVisible == true)
                      //   Positioned(
                      //     top: 0, // Adjust this value as needed
                      //     left: 25,
                      //     right: 5,
                      //     bottom: 400,
                      //     child: AnimatedContainer(
                      //       height: _isFilterVisible ? MediaQuery.of(context).size.height - kToolbarHeight - 50 - MediaQuery.of(context).viewInsets.bottom : 0,
                      //       duration: Duration(milliseconds: 300),
                      //       child: Card(
                      //         elevation: 4,
                      //         child: Padding(
                      //           padding: EdgeInsets.all(10),
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               SizedBox(height: 5),
                      //               Row(
                      //                 children: [
                      //                   Text('Price Range: ', style: TextStyle(fontFamily: 'Ubuntu', fontSize: 17)),
                      //                   SizedBox(width: 20),
                      //                   Container(
                      //                     height: 50,
                      //                     width: 80,
                      //                     decoration: BoxDecoration(
                      //                       border: Border.all(color: Colors.grey),
                      //                       borderRadius: BorderRadius.circular(5),
                      //                     ),
                      //                     child: TextFormField(
                      //                       keyboardType: TextInputType.number,
                      //                       decoration: InputDecoration(
                      //                         hintText: 'Min',
                      //                         focusedBorder: OutlineInputBorder(
                      //                           borderRadius: BorderRadius.circular(5),
                      //                         ),
                      //                         enabledBorder: OutlineInputBorder(
                      //                             borderSide: BorderSide(color: Colors.grey),
                      //                             borderRadius: BorderRadius.circular(5)
                      //                         ),
                      //                       ),
                      //                       onChanged: (value) {
                      //                         setState(() {
                      //                           _minPrice = int.tryParse(value);
                      //                         });
                      //                       },
                      //                     ),
                      //                   ),
                      //                   SizedBox(width: 10),
                      //                   Text(' To ', style: TextStyle(fontFamily: 'Ubuntu', fontSize: 17)),
                      //                   SizedBox(width: 10),
                      //                   Container(
                      //                     height: 50,
                      //                     width: 80,
                      //                     decoration: BoxDecoration(
                      //                       border: Border.all(color: Colors.grey),
                      //                       borderRadius: BorderRadius.circular(5),
                      //                     ),
                      //                     child: TextFormField(
                      //                       keyboardType: TextInputType.number,
                      //                       decoration: InputDecoration(
                      //                         hintText: 'Max',
                      //                         focusedBorder: OutlineInputBorder(
                      //                           borderRadius: BorderRadius.circular(5),
                      //                         ),
                      //                         enabledBorder: OutlineInputBorder(
                      //                             borderSide: BorderSide(color: Colors.grey),
                      //                             borderRadius: BorderRadius.circular(5)
                      //                         ),
                      //                       ),
                      //                       onChanged: (value) {
                      //                         setState(() {
                      //                           _maxPrice = int.tryParse(value);
                      //                         });
                      //                       },
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //               SizedBox(height: 15),
                      //               Row(
                      //                 mainAxisAlignment: MainAxisAlignment.center,
                      //                 children: [
                      //                   _isLoading
                      //                       ? Center(child: CircularProgressIndicator())
                      //                       : DropdownButton<String>(
                      //                         value: _selectedCategory,
                      //                         onChanged: (String? newValue) {
                      //                           setState(() {
                      //                             _selectedCategory = newValue;
                      //                           });
                      //                         },
                      //                         items: _categories.map((String category) {
                      //                           return DropdownMenuItem<String>(
                      //                             value: category,
                      //                             child: Text(category),
                      //                           );
                      //                         }).toList(),
                      //                         hint: Text('Select Category'),
                      //                   ),
                      //                   SizedBox(width: 20),
                      //                   DropdownButton<String>(
                      //                     value: _selectedAlphabeticOrder,
                      //                     onChanged: (String? newValue) {
                      //                       setState(() {
                      //                         _selectedAlphabeticOrder = newValue!;
                      //                       });
                      //                     },
                      //                     items: listOrder.map((String order) {
                      //                       return DropdownMenuItem<String>(
                      //                         value: order,
                      //                         child: Text(order),
                      //                       );
                      //                     }).toList(),
                      //                     hint: Text('Select Order'),
                      //                   ),
                      //                 ],
                      //               ),
                      //               SizedBox(height: 40),
                      //               Center(
                      //                 child: ElevatedButton(
                      //                   onPressed: () {
                      //                     filterProduct();
                      //                   },
                      //                   child: Text('Apply'),
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      if (_searchResults.isNotEmpty || _focusNode.hasFocus)
                        Positioned(
                          top: 5,
                          left: 20,
                          right: 20,
                          child: Container(
                            constraints: BoxConstraints(maxHeight: 300),
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
                                                category: result.category,
                                                description: result.description,
                                                productSKU: result.productSKU,
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
                  );
                }
              },
          )
              : SingleChildScrollView(
                child: Column(
                  children: _filterResults.isNotEmpty
                      ? _filterResults.map((product) {
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => productListScreen(
                                      title: product.title,
                                      category: product.category,
                                      description: product.description,
                                      productSKU: product.productSKU,
                                      saleprice: product.price.toInt(),
                                      compareprice: product.comparePrice.toInt(), // Example value
                                      storeName: product.storeName, // Example value
                                      phoneNum: product.phoneNum, // Example value
                                      email: product.email, // Example value
                                      imageURL1: product.imageUrl,
                                      imageURL2: product.imageURL2, // Example value
                                      imageURL3: product.imageURL3, // Example value
                                      imageURL4: product.imageURL4, // Example value
                                    ),
                                  ),
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
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        border: Border.all(color: Colors.black.withOpacity(0.3)),
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
                                    SizedBox(width: 5),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              width: 180,
                                              child: Text('${product.title}',
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
                                                  text: '${product.price}  ',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${product.comparePrice}',
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
                                              text: 'Store: ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: '${product.storeName}',
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
                                    SizedBox(width: 5),
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
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                addToCart(
                                                  product.title,
                                                  product.category,
                                                  product.price.toInt(),
                                                  product.comparePrice.toInt(), // Example value
                                                  product.description,
                                                  product.productSKU, // Example value
                                                  product.storeName, // Example value
                                                  product.phoneNum, // Example value
                                                  product.email, // Example value
                                                  product.imageUrl,
                                                  product.imageURL2, // Example value
                                                  product.imageURL3, // Example value
                                                  product.imageURL4,
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
                                                    title: product.title,
                                                    category: product.category,
                                                    description: product.description,
                                                    productSKU: product.productSKU,// Example value
                                                    saleprice: product.price.toInt(),
                                                    compareprice: product.comparePrice.toInt(), // Example value
                                                    storeName: product.storeName, // Example value
                                                    phoneNum: product.phoneNum, // Example value
                                                    email: product.email, // Example value
                                                    imageURL1: product.imageUrl,
                                                    imageURL2: product.imageURL2, // Example value
                                                    imageURL3: product.imageURL3, // Example value
                                                    imageURL4: product.imageURL4,
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
                              )
                          );
                        }).toList()
                      : [Padding(
                        padding: const EdgeInsets.symmetric(vertical: 300),
                        child: Center(child: Text('No products found')),
                      )],
                ),
          ),
        ),
      ),
    );
  }
}

class viewHistory extends StatefulWidget {
  const viewHistory({super.key});

  @override
  State<viewHistory> createState() => _viewHistoryState();
}

class _viewHistoryState extends State<viewHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text('Search History',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500)),
            ),
            Spacer(),
            IconButton(
              onPressed: () {

              },
              icon: Text("Clear"),
            ),
          ],
        ),
      ),
      body: Column(
        children: [

        ],
      ),
    );
  }
}

