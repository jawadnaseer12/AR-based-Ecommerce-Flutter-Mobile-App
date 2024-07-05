import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/productListScreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class checkoutProcess extends StatefulWidget {

  final String title;
  final int saleprice;
  final int compareprice;
  final String storeName;
  final String email;
  final int quantity;
  final String productSize;
  final String imageURL1;

  const checkoutProcess({
    required this.title,
    required this.saleprice,
    required this.compareprice,
    required this.storeName,
    required this.email,
    required this.quantity,
    required this.productSize,
    required this.imageURL1,
  });

  @override
  State<checkoutProcess> createState() => _checkoutProcessState();
}

class _checkoutProcessState extends State<checkoutProcess> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _consigneeName = TextEditingController();
  final TextEditingController _consigneeEmail = TextEditingController();
  final TextEditingController _consigneePhoneNo = TextEditingController();
  final TextEditingController _consigneeAddress = TextEditingController();
  final TextEditingController _addressTown = TextEditingController();

  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expirationDateController = TextEditingController();
  TextEditingController _securityCodeController = TextEditingController();

  List<String> cityCategories = ['Rawalpindi', 'Islamabad', 'Lahore', 'Karachi', 'Peshawar', 'Faisalabad ', 'Abbottabad', 'Attock', 'Chakwal', 'Quetta', 'Rahimyar Khan', 'Sahiwal'];
  String? _selectCity;
  String? _selectedPaymentOption;

  String fullName = '';
  String phoneNo = '';
  String address = '';
  String town = '';
  String orderNo = '';

  double _containerHeight = 130;

  String generateOrderNumber() {
    Random random = Random();
    String orderNumber = '';
    for (int i = 0; i < 15; i++) {
      orderNumber += random.nextInt(10).toString();
    }
    return orderNumber;
  }

  Future<void> sendEmail(String recipientEmail, String subject, String body) async {
    // User? user = FirebaseAuth.instance.currentUser;
    // String? email = user?.email;
    // String password = "";
    // final String? username = email;
    //
    // if (email != null){
    //   QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
    //       .collection('buyers')
    //       .where('email', isEqualTo: email)
    //       .limit(1) // Limit to 1 document as email should be unique
    //       .get();
    //
    //   if (querySnapshot.docs.isNotEmpty) {
    //     password = querySnapshot.docs.first.data()['password'];
    //     print('Password for current user: $password');
    //   } else {
    //     print('User document not found in Firestore for email: $email');
    //   }
    // } else {
    //   print('User is not authenticated.');
    // }

    final smtpServer = gmail('2012306@szabist-isb.pk', 'jawad4472391ali');
    final message = Message()
      ..from = Address('2012306@szabist-isb.pk')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..html = body;

    try{
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Error sending email: $e');
    }

  }

  void confirmOrder(String title, int saleprice, int compareprice, String productSize, int quantity, String imageUrl, int totalBill, String orderNumber) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.email;

    String sellerEmail = widget.email;
    String? buyerEmail = userId;
    String buyerSubject = 'New Order ${orderNumber} Confirmation';
    String buyerBody = 'Thank you for your order. You will get your order with in 2 to 4 working days!';
    String sellerSubject = 'Your have a New Order';
    String sellerBody = 'Dear Seller, Your have received a new order ${orderNumber} in Seller Center. Process it now!';

    FirebaseFirestore.instance.collection('buyers').doc(userId).collection('order').doc(orderNumber).set({
      'order number': orderNumber,
      'product title': title,
      'product price': saleprice,
      'discount price': compareprice,
      'product size': productSize,
      'quantity': quantity,
      'total bill': totalBill,
      'consignee name': _consigneeName.text.trim(),
      'consignee email': _consigneeEmail.text.trim(),
      'consignee phoneNo': _consigneePhoneNo.text.trim(),
      'consignee address': _consigneeAddress.text.trim(),
      'address town': _addressTown.text.trim(),
      'address city': _selectCity,
      'imageURL': imageUrl,
      'dateTime': FieldValue.serverTimestamp(),
    });

    FirebaseFirestore.instance.collection('sellers').doc(sellerEmail).collection('order').doc(orderNumber).set({
      'order number': orderNumber,
      'product title': title,
      'product price': saleprice,
      'discount price': compareprice,
      'product size': productSize,
      'quantity': quantity,
      'total bill': totalBill,
      'consignee name': _consigneeName.text.trim(),
      'consignee email': _consigneeEmail.text.trim(),
      'consignee phoneNo': _consigneePhoneNo.text.trim(),
      'consignee address': _consigneeAddress.text.trim(),
      'address town': _addressTown.text.trim(),
      'address city': _selectCity,
      'imageURL': imageUrl,
      'dateTime': FieldValue.serverTimestamp(),
    });

    alertMessage.showAlert(context, 'Success', 'You have Successfully Place Your Order against Order ID: ${orderNumber}\nYou will be notifiied soon via Email.');

    sendEmail(sellerEmail, sellerSubject, sellerBody);
    sendEmail(buyerEmail!, buyerSubject, buyerBody);

  }

  String? _validateName(String value) {
    RegExp regex = RegExp(r'^[a-zA-Z\s]+$');
    if (value == null || value.isEmpty) {
      return "Name is required";
    }
    if (!regex.hasMatch(value)) {
      return 'Enter a valid name containing only alphabets';
    }
    return null;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expirationDateController.dispose();
    _securityCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.email;
    int totalBill = widget.quantity * widget.saleprice;
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
                  child: Text('Checkout Process',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500)),
                ),
                IconButton(
                    onPressed: () {},
                    icon: Tooltip(
                      message: 'Kindly fill entry carefully!',
                      child: Icon(Icons.help),
                    ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    child: Text(
                      'Product Detail',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    height: 120,
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
                            // borderRadius: BorderRadius.circular(5),
                          ),
                          child: widget.imageURL1 != null
                              ? Image.network(widget.imageURL1, fit: BoxFit.cover)
                              : DecoratedBox(decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/product1.jpg'),
                              fit: BoxFit.cover,
                            ),
                          )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  width: 200,
                                  child: Text('${widget.title}',
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
                                      text: '${widget.saleprice}  ',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${widget.compareprice}',
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
                                      text: '${widget.storeName}',
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
                          padding: const EdgeInsets.only(top: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'Qty: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${widget.quantity}',
                                      style: TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Text('Qty: ${widget.quantity}', style: TextStyle(fontSize: 15)),
                              SizedBox(height: 30),
                              RichText(
                                text: TextSpan(
                                  text: 'Total Bill: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${totalBill}',
                                      style: TextStyle(
                                        fontSize: 13,
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
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    child: Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    height: 300,
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
                            controller: _consigneeName,
                            decoration: InputDecoration(
                              hintText: 'Consignee Name',
                              // fillColor: Color(0xffE5EFF0),
                              // filled: true,
                              suffixIcon: Icon(Icons.person),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                            ),
                            validator: (value) => _validateName(value!),
                            onChanged: (value) {
                              setState(() {
                                fullName = value;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: TextFormField(
                            controller: _consigneeEmail,
                            decoration: InputDecoration(
                              hintText: 'Email (Optional)',
                              // fillColor: Color(0xffE5EFF0),
                              // filled: true,
                              suffixIcon: Icon(Icons.alternate_email),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: TextFormField(
                            controller: _consigneePhoneNo,
                            decoration: InputDecoration(
                              hintText: 'Phone No',
                              // fillColor: Color(0xffE5EFF0),
                              // filled: true,
                              suffixIcon: Icon(Icons.phone),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone Number is required';
                              }
                              // if (!RegExp(r'^[0-9]*$').hasMatch(value) && !value.contains('+')) {
                              //   return 'Please use Country Code (+)';
                              // }
                              if (value.length != 11 || value.length > 12) {
                                return 'Phone number must be 11 digits long.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                phoneNo = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    child: Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    height: 300,
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
                            controller: _consigneeAddress,
                            decoration: InputDecoration(
                              hintText: 'Address',
                              // fillColor: Color(0xffE5EFF0),
                              // filled: true,
                              suffixIcon: Icon(Icons.home),
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
                                return "Address is Required";
                              }
                              return null;
                            }),
                            onChanged: (value) {
                              setState(() {
                                address = value;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: TextFormField(
                            controller: _addressTown,
                            decoration: InputDecoration(
                              hintText: 'Town',
                              // fillColor: Color(0xffE5EFF0),
                              // filled: true,
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
                                return "Town is Required";
                              }
                              return null;
                            }),
                            onChanged: (value) {
                              setState(() {
                                town = value;
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Container(
                            height: 60,
                            width: 380,
                            child: DropdownButtonFormField<String>(
                              value: _selectCity,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectCity = newValue;
                                });
                              },
                              items: cityCategories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                hintText: 'City',
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10)
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
                    padding: const EdgeInsets.only(left: 15, top: 10),
                    child: Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
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
                          title: Text('Add Credit or Debit Card'),
                          value: 'Online',
                          groupValue: _selectedPaymentOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentOption = value;
                              _containerHeight = value == 'Online' ? 320 : 130;
                            });
                          },
                        ),
                        Visibility(
                          visible: _selectedPaymentOption == 'Online',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _cardNumberController,
                                decoration: InputDecoration(
                                  labelText: 'Card Number',
                                  hintText: 'Enter card number',
                                  contentPadding: EdgeInsets.only(top: 20, left: 10),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blueAccent),
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: _securityCodeController,
                                decoration: InputDecoration(
                                  labelText: 'CCV',
                                  hintText: 'Enter security code',
                                  contentPadding: EdgeInsets.only(top: 20, left: 10),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blueAccent),
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: _expirationDateController,
                                keyboardType: TextInputType.numberWithOptions(decimal: false),
                                maxLength: 5,
                                decoration: InputDecoration(
                                  labelText: 'Expire Data',
                                  hintText: 'MM/YY',
                                  contentPadding: EdgeInsets.only(top: 20, left: 10),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.blueAccent),
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                ),
                                onChanged: (text) {
                                  if (text.length == 2 && !_expirationDateController.text.contains('/')) {
                                    _expirationDateController.value = _expirationDateController.value.copyWith(
                                      text: text + '/',
                                      selection: TextSelection.collapsed(offset: text.length + 1),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        RadioListTile<String>(
                          title: Text('Cash on Delivery'),
                          value: 'COD',
                          groupValue: _selectedPaymentOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentOption = value;
                              _containerHeight = 130;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 45),
                  Center(
                    child: Container(
                      height: 50,
                      width: 300,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if(_formKey.currentState!.validate())
                          {
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
                            orderNo = generateOrderNumber();
                            print("Order Number: ${orderNo}");
                            confirmOrder(widget.title, widget.saleprice, widget.compareprice, widget.productSize, widget.quantity, widget.imageURL1, totalBill, orderNo);
                          }
                        },
                        child: Center(
                          child: Text(
                            'CONFIRM ORDER',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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
