import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stitchhub_app/UserAuthentication/passwordUpdated.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class createNewPasseord extends StatefulWidget {
  const createNewPasseord({super.key});

  @override
  State<createNewPasseord> createState() => _createNewPasseordState();
}

class _createNewPasseordState extends State<createNewPasseord> {

  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;
  bool obsecure = true;
  String newPassword = '';
  String confirmNewPassword = '';

  Future<void> _submitPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.currentUser!.updatePassword(_newPasswordController.text);
      alertMessage.showAlert(context, 'Success', 'Password updated successfully.');
    } catch (e) {
      print(e.toString());
      alertMessage.showAlert(context, 'Error', 'Failed to update password.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                Image(
                  image: AssetImage('assets/newpassword.png'),
                  height: 200.h,
                ),
                SizedBox(height: 10.h),
                Text('Create Your New Password',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 5.h),
                Text('Choose a secure password that will',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                Text('be easy for you to remember',
                    style: TextStyle(fontSize: 17, color: Colors.white)),
                SizedBox(height: 50.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Container(
                    height: 60.h,
                    width: double.infinity.w,
                    child: TextFormField(
                      controller: _newPasswordController,
                      autofocus: true,
                      obscureText: obsecure,
                      decoration: InputDecoration(
                        hintText: 'Enter New Password',
                        hintStyle: TextStyle(fontSize: 15),
                        prefixIcon: Icon(Icons.lock),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 8) {
                          return 'Password at least 8 characters long';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          newPassword = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Container(
                    height: 60.h,
                    width: double.infinity.w,
                    child: TextFormField(
                      autofocus: true,
                      obscureText: obsecure,
                      decoration: InputDecoration(
                        hintText: 'Enter Confirm Password',
                        hintStyle: TextStyle(fontSize: 15),
                        prefixIcon: Icon(Icons.lock),
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
                      validator: (value) {
                        if (value == null || value.isEmpty)
                        {
                          return 'Please confirm your new password';
                        } else if (value != newPassword)
                        {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      onChanged: (value)
                      {
                        setState(()
                        {
                          confirmNewPassword = value;
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
                        'CONTINUE',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        _submitPassword();
                        if(_formKey.currentState!.validate())
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => passwordUpdated()),
                          );
                        }
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

