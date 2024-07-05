import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stitchhub_app/Dashboard/databaseService.dart';
import 'package:stitchhub_app/UserAuthentication/controller/signup_controller.dart';
import 'package:stitchhub_app/UserAuthentication/login.dart';
import 'package:stitchhub_app/UserAuthentication/otpVerification.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:stitchhub_app/UserAuthentication/registerOTPVerification.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class buyerRegister extends StatefulWidget {
  const buyerRegister({super.key});

  @override
  State<buyerRegister> createState() => _buyerRegisterState();
}

class _buyerRegisterState extends State<buyerRegister> {

  final _formKey = GlobalKey<FormState>();
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final controller = Get.put(SignUpController());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String fullName = '';
  String userName = '';
  String emailPhoneNo = '';
  String password = '';
  bool obsecure = true;
  String otp = '';

  void _submitBuyerForm(){
    String email = _emailController.text.trim();
    String fullName = _fullnameController.text.trim();
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    databaseService dataService = databaseService(context);
    dataService.storeBuyerInfo(email, fullName, username, password);
  }

  String generateOTP() {
    Random random = Random();
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
                  SizedBox(height: 50.h),
                  Text('Register Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 5.h),
                  Text('Just one step away from Registration', style: TextStyle(fontSize: 17, color: Colors.white)),
                  SizedBox(height: 50.h),
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
                              borderRadius: BorderRadius.circular(50)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)
                          ),
                        ),
                        validator: ((value) {
                          if (value == null || value.isEmpty) {
                            return "Email is required";
                          }
                          if (value != value.toLowerCase()) {
                            return "Please enter email in lowercase";
                          }
                          if (!value.contains("@") || !value.contains('gmail.com')) {
                            return "Please enter correct format of email";
                          }
                          return null;
                        }),
                        onChanged: (value) {
                          setState(() {
                            emailPhoneNo = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: Container(
                      height: 60.h,
                      width: double.infinity.w,
                      child: TextFormField(
                        controller: _fullnameController,
                        decoration: InputDecoration(
                          hintText: 'Enter Full Name',
                          hintStyle: TextStyle(fontSize: 15),
                          prefixIcon: Icon(Icons.person),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(50)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)
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
                  ),
                  SizedBox(height: 20.h),
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
                              borderRadius: BorderRadius.circular(50)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)
                          ),
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
                  SizedBox(height: 20.h),
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
                              borderRadius: BorderRadius.circular(50)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)
                          ),
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
                  SizedBox(height: 50.h),
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
                          'SIGN UP',
                          style:
                          TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if(_formKey.currentState!.validate())
                          {
                            otp = generateOTP();
                            print('OTP: ${otp}');
                            sendOtpToEmail(emailPhoneNo, otp);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => registerOTPVerification(verificationId: otp)),
                            );
                            // _submitBuyerForm();
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => otpVerification()));
                           // SignUpController.instance.registerUser(controller.email.text.trim(), controller.password.text.trim());
                           //  Navigator.push(context, MaterialPageRoute(builder: (context) => messageGenerated()));
                           //  _registerUser();
                            // final user = UserModel(
                            //     email: controller.email.text.trim(),
                            //     fullname: controller.fullname.text.trim(),
                            //     username: controller.username.text.trim(),
                            //     password: controller.password.text.trim(),
                            // );
                            // SignUpController.instance.createUser(user)
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
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

