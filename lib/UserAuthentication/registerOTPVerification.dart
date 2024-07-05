import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stitchhub_app/Dashboard/databaseService.dart';
import 'package:stitchhub_app/UserAuthentication/createNewPassword.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class registerOTPVerification extends StatefulWidget {
  // const registerOTPVerification({super.key});

  final String verificationId;

  registerOTPVerification({required this.verificationId});

  @override
  State<registerOTPVerification> createState() => _registerOTPVerificationState();
}

class _registerOTPVerificationState extends State<registerOTPVerification> {

  // TextEditingController textEditingController = TextEditingController();
  // TextEditingController _otpController = TextEditingController();

  final TextEditingController _otpController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String pinCode = '';
  // String verificationId = '617628';

  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  Future<void> _submitOtp() async {
    final String otpCode = _otpController.text.trim();
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode: otpCode);

    try{
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.push(context, MaterialPageRoute(builder: (context) => createNewPasseord()));
      print('Successfully signed in with OTP');
    } catch (e) {
      print('Error signing in with OTP: $e');
      alertMessage.showAlert(context, 'Error', 'Invalid OTP code');
    }
  }

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    _otpController.dispose();
    super.dispose();
  }

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // void _submitOtpButton(){
  //   String otp = _otpController.text.trim();
  //
  //   databaseService dataService = databaseService(context);
  //   dataService.verifyOTP(otp);
  // }

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
                GestureDetector(
                  onTap: () {},
                  child: Padding(
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
                ),
                Image(
                  image: AssetImage('assets/otpcode.png'),
                  alignment: Alignment.center,
                  height: 200.h,
                ),
                Text('OTP Verification', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
                SizedBox(height: 5.h),
                Text('We send 6 digit code to your',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                Text('email or phone number',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                SizedBox(height: 40.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45),
                    child: Text(
                      'Enter OTP Code',
                      style: TextStyle(
                          color: Colors.black45,
                          fontSize: 20,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
                Form(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 45,
                    ),
                    child: PinCodeTextField(
                      controller: _otpController,
                      appContext: context,
                      pastedTextStyle: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,
                      // obscureText: true,
                      obscuringCharacter: '*',
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 40.h,
                        fieldWidth: 35.w,
                        activeFillColor: Colors.white,
                      ),
                      cursorColor: Colors.black,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      errorAnimationController: errorController,
                      // controller: textEditingController,
                      keyboardType: TextInputType.number,
                      boxShadows: const [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: Colors.black12,
                          blurRadius: 10,
                        )
                      ],
                      onCompleted: (v) {
                        debugPrint("Completed");
                      },
                      // onTap: () {
                      //   print("Pressed");
                      // },
                      onChanged: (value) {
                        debugPrint(value);
                        setState(() {
                          currentText = value;
                        });
                      },
                      beforeTextPaste: (text) {
                        debugPrint("Allowing to paste $text");
                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                        return true;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    hasError ? "*Please Enter Pin Code" : "",
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Didn`t Receive OTP?', style: TextStyle(fontSize: 15, color: Colors.black45, fontWeight: FontWeight.bold),),
                    SizedBox(width: 5.w),
                    Text('Resend OTP', style: TextStyle(fontSize: 15, color: Color(0xff6C63FF), decoration: TextDecoration.underline, fontWeight: FontWeight.bold),),
                  ],
                ),
                SizedBox(height: 40.h),
                Container(
                  height: 50.h,
                  width: 270.w,
                  decoration: BoxDecoration(
                    color: Color(0xff6C63FF),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        _submitOtp();
                      },
                      child: Text(
                        'VERIFY',
                        style:
                        TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: TextButton(
                        child: const Text("Clear", style: TextStyle(fontSize: 17)),
                        onPressed: () {
                          _otpController.clear();
                        },
                      ),
                    ),
                    // Flexible(
                    //   child: TextButton(
                    //     child: const Text("Set Text"),
                    //     onPressed: () {
                    //       setState(() {
                    //         textEditingController.text = "1234";
                    //       });
                    //     },
                    //   ),
                    // ),
                  ],
                )
              ],
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
