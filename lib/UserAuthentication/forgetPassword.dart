import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stitchhub_app/Dashboard/databaseService.dart';
import 'package:stitchhub_app/UserAuthentication/login.dart';
import 'package:stitchhub_app/UserAuthentication/otpVerification.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class forgetPassword extends StatefulWidget {
  const forgetPassword({super.key});

  @override
  State<forgetPassword> createState() => _forgetPasswordState();
}

class _forgetPasswordState extends State<forgetPassword> {

  final _formKey = GlobalKey<FormState>();
  // TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailOrPhoneController = TextEditingController();

  String email = '';

  Future<void> _submitEmailOrPhoneNumber() async {
    final String emailOrPhoneNumber = _emailOrPhoneController.text.trim();

    try{
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: emailOrPhoneNumber,

          verificationCompleted: (PhoneAuthCredential credential) {

          },
          verificationFailed: (FirebaseAuthException e) {
            print('Error sending OTP: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => otpVerification(verificationId: verificationId),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
          },
      );
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }

  void _submitButton(){
    String emailOrPhoneNumber = _emailOrPhoneController.text.trim();

    databaseService dataService = databaseService(context);
    dataService.sendLink(emailOrPhoneNumber);
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
                Image(
                  image: AssetImage('assets/securepass.png'),
                    height: 170.h,
                ),
                SizedBox(height: 50.h),
                Text('Forget Password?',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 5.h),
                Text('Enter Your Email Address to get OTP',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                SizedBox(height: 40.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Container(
                    height: 60.h,
                    width: double.infinity.w,
                    child: TextFormField(
                      controller: _emailOrPhoneController,
                      // controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter Email or Phone No',
                        hintStyle: TextStyle(fontSize: 15),
                        prefixIcon: _emailOrPhoneController.text.contains('@')
                            ? Icon(Icons.email)
                            : Icon(Icons.phone),
                        // prefixIcon: Icon(Icons.email),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent),
                            borderRadius: BorderRadius.circular(50)
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email or Phone No is required';
                        } else if (!value.contains('@') && !value.contains(RegExp(r'^[+0-9]*$'))) {
                          return 'Please enter a valid email or phone no';
                        }
                        return null;
                        // !value.contains('@')
                      },
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                Container(
                  height: 50.h,
                  width: 270.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: TextButton(
                      child: Text(
                        'CONTINUE',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if(_formKey.currentState!.validate())
                        {

                          _submitEmailOrPhoneNumber();
                          // if(_emailOrPhoneController.text.contains('@')){
                          //   _submitButton();
                          // }
                          // else{
                          //   _submitEmailOrPhoneNumber();
                          // }
                          // _submitEmailOrPhoneNumber();
                          // _submitButton();
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => otpVerification()));
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
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
                        'BACK TO LOG IN',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => login()),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    super.dispose();
  }

}

