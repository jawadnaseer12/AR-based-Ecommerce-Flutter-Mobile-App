import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/buyerDashboard.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/sellerDashboard.dart';
import 'package:stitchhub_app/UserAuthentication/createNewPassword.dart';
import 'package:stitchhub_app/UserAuthentication/otpVerification.dart';

class databaseService{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BuildContext context;

  databaseService(this.context);

  Future<void> checkloginForm(String email, String password, bool rememberMe) async {

    showDialog(
        context: context,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ));

    try{

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (rememberMe) {
        saveCredentials(email, password);
      }

      final String userEmail = userCredential.user!.email!;

      final QuerySnapshot sellerSnapshot = await _firestore
          .collection('sellers')
          .where('email', isEqualTo: userEmail)
          .get();

      final QuerySnapshot buyerSnapshot = await _firestore
          .collection('buyers')
          .where('email', isEqualTo: userEmail)
          .get();

      if(sellerSnapshot.docs.isNotEmpty){
        Navigator.push(context, MaterialPageRoute(builder: (context) => sellerDashboard()));
      }
      else if(buyerSnapshot.docs.isNotEmpty){
        Navigator.push(context, MaterialPageRoute(builder: (context) => buyerDashboard()));
      }
      else {
        print('User does not exist');
        alertMessage.showAlert(context, 'Error', 'User does not exist');
      }
    } catch (e) {
      print('Error signing in: $e');
      alertMessage.showAlert(context, 'Error', 'Invalid Email or Password');
    }
  }

  void saveCredentials(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);
  }

  Future<void> storeBuyerInfo(String email, String fullName, String username, String password) async {
    try{
      await registerUser(email, password);
      await _firestore.collection('buyers').doc(email).set({
        'email': email,
        'fullName': fullName,
        'username': username,
        'password': password,
        'time': FieldValue.serverTimestamp(),
      });
      print('Buyer Account created successfully!');
      alertMessage.showAlert(context, 'Success', 'Buyer Account created successfully!');
    } catch (e) {
      print('Failed to Create Buyer Account: $e');
      alertMessage.showAlert(context, 'Error', 'Failed to Create Buyer Account: $e');
    }
  }

  Future<void> storeSellerInfo(String ownerName, String storeName, String email, String phoneNum, String username, String password) async {

    try{
      await registerUser(email, password);
      await _firestore.collection('sellers').doc(email).set({
        'ownerName': ownerName,
        'storeName': storeName,
        'userame': username,
        'email': email,
        'phoneNum': phoneNum,
        'password': password,
        'time': FieldValue.serverTimestamp(),
      });
      print('Seller Account created successfully!');
      alertMessage.showAlert(context, 'Success', 'Seller Account created successfully!');
    } catch (e) {
      print('Failed to Create Seller Account: $e');
      alertMessage.showAlert(context, 'Error', 'Failed to Create Seller Account: $e');
    }
  }

  Future<void> registerUser(String email, String password) async {
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
      );
      print('User successfully registered in authentication');
    } catch (e) {
      print('Error registering user: $e');
    }
  }

  Future<void> sendLink(String email) async {
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      alertMessage.showAlert(context, 'Success', 'A link has been send on your email');
      // Navigator.push(context, MaterialPageRoute(builder: (context) => otpVerification()));
    } catch (e) {
      print('OTP Error : $e');
      alertMessage.showAlert(context, 'Error', 'Email not Exist - Try another one!');
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        print('Facebook login successful, accessToken: ${accessToken.token}');
      } else {
        print('Facebook login failed: ${result.status}');
      }

    } catch (e) {
      print('Facebook login failed: $e');
    }
  }

  //
  // Future<void> verifyOTP(String otp) async {
  //   try{
  //     await FirebaseAuth.instance.verifyPasswordResetCode(otp);
  //     Navigator.push(context, MaterialPageRoute(builder: (context) => createNewPasseord()));
  //   } catch (e) {
  //     print('OTP Not Verify : $e');
  //     alertMessage.showAlert(context, 'Error', 'Invalid OTP - Please Enter Correct OTP!');
  //   }
  // }

  // Future<void> resetPassword(String newPassword) async {
  //   try {
  //     await FirebaseAuth.instance.confirmPasswordReset(
  //       code: _otpController.text,
  //       newPassword: newPassword,
  //     );
  //     // Password reset successful, navigate to login screen or home screen
  //   } catch (e) {
  //     print('Password Not be Reset : $e');
  //   }
  // }

  // Future<void> signInWithEmailAndPassword(String email, String password) async {
  //
  //   try{
  //     final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: email,
  //         password: password,
  //     );
  //
  //     final String uid = userCredential.user!.uid;
  //
  //     final QuerySnapshot sellerSnapshot = await FirebaseFirestore.instance.collection('sellers').where('uid', isEqualTo: uid).get();
  //
  //     if(sellerSnapshot.docs.isNotEmpty){
  //       print('Seller Snapshot: $sellerSnapshot');
  //       Navigator.push(context, MaterialPageRoute(builder: (context) => sellerDashboard()));
  //     } else {
  //       final QuerySnapshot buyerSnapshot = await FirebaseFirestore.instance.collection('buyers').where('uid', isEqualTo: uid).get();
  //       if(buyerSnapshot.docs.isNotEmpty){
  //         print('Buyer Snapshot: $buyerSnapshot');
  //         Navigator.push(context, MaterialPageRoute(builder: (context) => buyerDashboard()));
  //       } else {
  //         print('User does not exist');
  //       }
  //     }
  //   } catch (e) {
  //     print('Error signing in: $e');
  //   }
  // }

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