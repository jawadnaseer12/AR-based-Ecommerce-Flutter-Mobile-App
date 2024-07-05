import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stitchhub_app/Dashboard/databaseService.dart';
import 'package:stitchhub_app/UserAuthentication/login.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:stitchhub_app/UserAuthentication/messageGenerated.dart';
import 'package:stitchhub_app/UserAuthentication/otpVerification.dart';
import 'package:stitchhub_app/UserAuthentication/sellerOTPVerification.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class sellerRegister extends StatefulWidget {
  const sellerRegister({super.key});

  @override
  State<sellerRegister> createState() => _sellerRegisterState();
}

class _sellerRegisterState extends State<sellerRegister> {

  final _formKey = GlobalKey<FormState>();

  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _ownernameController = TextEditingController();
  final TextEditingController _storenameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _submitSellerForm(){
    String ownerName = _ownernameController.text.trim();
    String storeName = _storenameController.text.trim();
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String phoneNum = _phoneNoController.text.trim();
    String password = _passwordController.text.trim();

    databaseService dataService = databaseService(context);
    dataService.storeSellerInfo(ownerName, storeName, email, phoneNum, username, password);
  }

  String fullName = '';
  String storeName = '';
  String userName = '';
  String email = '';
  String phoneNo = '';
  String password = '';
  String otp = '';
  bool obsecure = true;

  String generateOTP() {
    Random random = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  Future<void> sendOtpToEmail(String email, String otp) async {

    final smtpServer = gmail('2012306@szabist-isb.pk', 'jawad4472391ali');
    final message = Message()
      ..from = Address('2012306@szabist-isb.pk')
      ..recipients.add(email)
      ..subject = 'Your OTP Verification Code'
      ..text = 'Your OTP is: $otp\n\nPlease use this code to verify your account.'
      ..html = '<p>Your OTP is: <strong>$otp</strong></p>'
          '<p>Please use this code to verify your account.</p>';

    try {
      final sendReport = await send(message, smtpServer);
      print('OTP sent to $email');
      print('Message sent: ${sendReport.toString()}');
    } catch (e) {
      print('Error sending OTP: $e');
    }
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
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/coverpage.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, top: 50),
                    child: Row(
                      children: [
                        Container(
                          height: 45.h,
                          width: 45.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.navigate_before_outlined),
                            iconSize: 30,
                            color: Color(0xff6C63FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text('Welcome to Seller Center!',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text('Fill your detail to build online store',
                      style: TextStyle(fontSize: 17, color: Colors.white)),
                  SizedBox(height: 30.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: Container(
                      height: 60.h,
                      width: double.infinity.w,
                      child: TextFormField(
                        controller: _ownernameController,
                        decoration: InputDecoration(
                          hintText: 'Enter Owner Name',
                          hintStyle: TextStyle(fontSize: 15),
                          // fillColor: Color(0xffE5EFF0),
                          // filled: true,
                          prefixIcon: Icon(Icons.person),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        validator: (value) => _validateName(value!),
                        onChanged: (value) {
                          setState(() {
                            fullName = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: Container(
                      height: 60.h,
                      width: double.infinity.w,
                      child: TextFormField(
                        controller: _storenameController,
                        decoration: InputDecoration(
                          hintText: 'Enter Store Name',
                          hintStyle: TextStyle(fontSize: 15),
                          // fillColor: Color(0xffE5EFF0),
                          // filled: true,
                          prefixIcon: Icon(Icons.store),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return "Store Name is required";
                          }
                          return null;
                        }),
                        onChanged: (value) {
                          setState(() {
                            storeName = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: Container(
                      height: 60.h,
                      width: double.infinity.w,
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Enter Username',
                          hintStyle: TextStyle(fontSize: 15),
                          // fillColor: Color(0xffE5EFF0),
                          // filled: true,
                          prefixIcon: Icon(Icons.alternate_email),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return 'Username is required';
                          } else if (!value.startsWith('@')) {
                            return 'Username must start with @';
                          }
                          return null;
                        }),
                        onChanged: (value) {
                          setState(() {
                            userName = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: Container(
                      height: 60.h,
                      width: double.infinity.w,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter Email Address',
                          hintStyle: TextStyle(fontSize: 15),
                          // fillColor: Color(0xffE5EFF0),
                          // filled: true,
                          prefixIcon: Icon(Icons.email),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email Address is required';
                          } else if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          if (value != value.toLowerCase()) {
                            return "Please enter email in lowercase";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: Container(
                      height: 60.h,
                      width: double.infinity.w,
                      child: TextFormField(
                        controller: _phoneNoController,
                        autofocus: true,
                        // obscureText: obsecure,
                        decoration: InputDecoration(
                          hintText: 'Enter Phone Number',
                          hintStyle: TextStyle(fontSize: 15),
                          // fillColor: Color(0xffE5EFF0),
                          // filled: true,
                          prefixIcon: Icon(Icons.call),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone Number is required';
                          }
                          if (!RegExp(r'^[0-9]*$').hasMatch(value) && !value.contains('+')) {
                            return 'Please use Country Code (+)';
                          }
                          if (value.length != 13 || value.length > 13) {
                            return 'Phone number must be 12 digits long with Country Code.';
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
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: Container(
                      height: 60.h,
                      width: double.infinity.w,
                      child: TextFormField(
                        controller: _passwordController,
                        autofocus: true,
                        obscureText: obsecure,
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
                          hintStyle: TextStyle(fontSize: 15),
                          // fillColor: Color(0xffE5EFF0),
                          // filled: true,
                          prefixIcon: Icon(Icons.lock_open_outlined),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              obsecure = !obsecure;
                              setState(() {});
                            },
                            child: Icon(obsecure
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(50)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 8 || value.length > 20) {
                            return "Length of password should be atleast 8 characters long";
                          }
                          return null;
                        }),
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Container(
                    height: 50.h,
                    width: 270.w,
                    decoration: BoxDecoration(
                      color: Color(0xff6C63FF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: TextButton(
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if(_formKey.currentState!.validate())
                            {
                              otp = generateOTP();
                              print('OTP: ${otp}');
                              sendOtpToEmail(email, otp);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => sellerOTPVerification(verificationId: otp)),
                              );
                              // _submitSellerForm();
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => otpVerification()));
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => messageGenerated()));
                            }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Have an account?', style: TextStyle(fontSize: 15, color: Colors.black),),
                      TextButton(
                        child: Text('LOG IN', style: TextStyle(fontSize: 15, color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => login()),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

