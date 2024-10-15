import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/buyerDashboard.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/addProduct.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/orderManagement.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/productManagement.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/sellerDashboard.dart';
import 'package:stitchhub_app/UserAuthentication/demo.dart';
import 'package:stitchhub_app/UserAuthentication/google_sign_in.dart';
import 'package:stitchhub_app/UserAuthentication/login.dart';
import 'package:stitchhub_app/UserAuthentication/otpVerification.dart';
// import 'package:stitchhub_app/UserAuthentication/repository/authentication_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDg6j1BmO66xIpU8ULYgvpoRG1spu8tqbc",
        appId: "1:416332909857:android:596fb89bb8292a30314260",
        messagingSenderId: "416332909857",
        projectId: "stitch-hub-mobile-app",
        storageBucket: "stitch-hub-mobile-app.appspot.com"
      ));

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');
  String? password = prefs.getString('password');
  bool isLoggedIn = false;

  if(email != null && password != null) {
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      isLoggedIn = true;
    } catch (e) {
      print('Auto login failed: $e');
    }
  }
  // await Firebase.initializeApp();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      child: ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: MaterialApp(
          // themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: isLoggedIn ? getDashboard() : login(),
        ),
      ),
    );
  }

  Widget getDashboard() {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? userEmail = user?.email;

    return FutureBuilder<Widget>(
      future: getUserDashboard(userEmail),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return login();
          } else {
            return snapshot.data ?? login();
          }
        }
      },
    );
  }

  Future<Widget> getUserDashboard(String? userEmail) async {
    if (userEmail != null) {
      final QuerySnapshot sellerSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .where('email', isEqualTo: userEmail)
          .get();

      final QuerySnapshot buyerSnapshot = await FirebaseFirestore.instance
          .collection('buyers')
          .where('email', isEqualTo: userEmail)
          .get();

      if (buyerSnapshot.docs.isNotEmpty) {
        return buyerDashboard();
      } else if (sellerSnapshot.docs.isNotEmpty) {
        return sellerDashboard();
      }
    }
    return login();
  }
}
