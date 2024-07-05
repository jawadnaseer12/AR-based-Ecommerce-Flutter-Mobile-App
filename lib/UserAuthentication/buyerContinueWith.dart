import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:stitchhub_app/Dashboard/databaseService.dart';
import 'package:stitchhub_app/UserAuthentication/buyerRegister.dart';
import 'package:stitchhub_app/UserAuthentication/google_sign_in.dart';
import 'package:stitchhub_app/UserAuthentication/login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class buyerContinueWith extends StatefulWidget {
  const buyerContinueWith({super.key});

  @override
  State<buyerContinueWith> createState() => _buyerContinueWithState();
}

class _buyerContinueWithState extends State<buyerContinueWith> {
  // Future<UserCredential?> signInwithGoogle() async{
  //
  //   try{
  //     GoogleSignIn googleSignIn = GoogleSignIn(
  //       clientId: '416332909857-dlc396tdbki5lfdvcu48d856uvaa9vnf.apps.googleusercontent.com',
  //     );
  //
  //     GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  //
  //     AuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth?.accessToken,
  //         idToken: googleAuth?.idToken,
  //     );
  //
  //     // UserCredential userCredential =
  //     return await FirebaseAuth.instance.signInWithCredential(credential);
  //     // print(userCredential.user?.displayName);
  //   }
  //   catch (error)
  //   {
  //     print('Error signing in with Google: $error');
  //     return null;
  //   }
  // }

  void _facebookSubmitButton() {
    databaseService dataService = databaseService(context);
    dataService.signInWithFacebook();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              Image(
                image: AssetImage('assets/shoplogo.png'),
                alignment: Alignment.topCenter,
              ),
              SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.only(right: 80),
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Complete your Registration to get friendly experience',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40.h),
              Container(
                height: 50.h,
                width: 250.w,
                decoration: BoxDecoration(
                  color: Color(0xff6C63FF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: TextButton(
                    child: Text(
                      'REGISTER NOW',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => buyerRegister()),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                'OR',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 40.h),
              GestureDetector(
                onTap: () {
                  final provider =
                      Provider.of<GoogleSignInProvider>(context, listen: false);
                  provider.googleLogin();
                  // signInwithGoogle().then((UserCredential) {
                  //   if(UserCredential != null){
                  //     User? user = UserCredential.user;
                  //     if(user != null){
                  //       print('User ID: ${user.uid}');
                  //       print('Display Name: ${user.displayName}');
                  //       print('Email: ${user.email}');
                  //     }
                  //     // print('User signed in with Google');
                  //     // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => login()));
                  //   } else {
                  //     print('Sign in with Google failed');
                  //   }
                  // });
                  // signInwithGoogle();
                },
                child: Container(
                  height: 50.h,
                  width: 250.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.google,
                          color: Colors.blue, size: 24.0),
                      // Image(image: AssetImage('google.png'), height: 24.0,),
                      SizedBox(width: 5.w),
                      Text(
                        'CONTINUE WITH GOOGLE',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              // Container(
              //   height: 50,
              //   width: 250,
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(100),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Image(image: AssetImage('google.png'), height: 24.0,),
              //       SizedBox(width: 5),
              //       // Text(
              //       //   'CONTINUE WITH GOOGLE',
              //       //   style:
              //       //   TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
              //       // ),
              //       ElevatedButton(
              //           onPressed: () {
              //             signInwithGoogle();
              //           },
              //           child: Text(
              //             'CONTINUE WITH GOOGLE',
              //             style:
              //             TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
              //           ),
              //       ),
              //     ],
              //   ),
              // ),
              // ElevatedButton.icon(
              //   style: ButtonStyle(
              //     foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
              //     // textStyle: MaterialStateProperty.all<Color>(Colors.black),
              //   ),
              //     icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
              //     label: Text('CONTINUE WITH Google'),
              //     onPressed: () {
              //       final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
              //       provider.googleLogin();
              //     },
              // ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () {
                  _facebookSubmitButton();
                },
                child: Container(
                  height: 50.h,
                  width: 250.w,
                  decoration: BoxDecoration(
                    color: Color(0xff6C48D3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.facebook,
                          color: Colors.white, size: 24.0),
                      // Image(image: AssetImage('facebook.png'), height: 24.0,),
                      SizedBox(width: 5.w),
                      Text(
                        'CONTINUE WITH FACEBOOK',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                height: 50.h,
                width: 250.w,
                decoration: BoxDecoration(
                  color: Color(0xff2027DF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(FontAwesomeIcons.microsoft,
                        color: Colors.orange, size: 24.0),
                    // Image(image: AssetImage('microsoft.png'), height: 24.0,),
                    SizedBox(width: 5.w),
                    Text(
                      'CONTINUE WITH MICROSOFT',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
