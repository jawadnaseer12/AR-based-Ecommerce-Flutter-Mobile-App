import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stitchhub_app/Dashboard/BuyerDashboard/buyerDashboard.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/sellerDashboard.dart';
import 'package:stitchhub_app/Dashboard/databaseService.dart';
import 'package:stitchhub_app/UserAuthentication/forgetPassword.dart';
import 'package:stitchhub_app/UserAuthentication/roleBase.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool rememberMe = false;
  bool obsecure = true;
  String emailNum = '';
  String password = '';
  bool _isButtonPressed = false;
  bool _isCreateButtonPressed = false;
  bool _isLoading = false;

  void _loginForm(){

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    databaseService dataService = databaseService(context);
    dataService.checkloginForm(email, password, rememberMe);

  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _buildLoginForm(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 70.h),
            Image(
              image: AssetImage('assets/shoplogo.png'),
              alignment: Alignment.topCenter,
            ),
            SizedBox(height: 30.h),
            Text(
              'Welcome Here!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: Container(
                height: 60.h,
                width: double.infinity.w,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email or Phone No',
                    hintStyle: TextStyle(fontSize: 15),
                    // fillColor: Colors.white,
                    // filled: true,
                    prefixIcon: Icon(Icons.person),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(50)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  validator: ((value) {
                    if (value == null || value.isEmpty) {
                      return "Email or Number is required";
                    }
                    // if (!value.contains("@") || value.length != 11 || value.length > 11) {
                    //   return "Please enter correct format of email or number";
                    // }
                    return null;
                  }),
                  onChanged: (value) {
                    setState(() {
                      emailNum = value;
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
                  controller: _passwordController,
                  autofocus: true,
                  obscureText: obsecure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(fontSize: 15),
                    // fillColor: Colors.white,
                    // filled: true,
                    prefixIcon: Icon(Icons.lock),
                    //suffixIcon: Icon(Icons.visibility_off),
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
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Checkbox(
                        value: rememberMe,
                        activeColor: Colors.white,
                        checkColor: Colors.blueAccent,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                      Text('Remember Me'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => buyerDashboard()),
            //     );
            //   },
            //   child:
            GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isButtonPressed = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  _isButtonPressed = false;
                });
              },
              onTapCancel: () {
                setState(() {
                  _isButtonPressed = false;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 50.h,
                width: 270.w,
                decoration: BoxDecoration(
                  color: _isButtonPressed ? Colors.blueAccent.withOpacity(0.3) : Color(0xff6C63FF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      if(_formKey.currentState!.validate())
                      {
                        _loginForm();
                      }
                      // _submitLoginForm();
                    },
                    child: Text(
                      'LOG IN',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            // Container(
            //   height: 40,
            //   width: 300,
            //   decoration: BoxDecoration(
            //     color: Color(0xff6C63FF),
            //     borderRadius: BorderRadius.circular(100),
            //   ),
            //   child: Center(
            //     child: TextButton(
            //       onPressed: () {
            //         _submitLoginForm();
            //       },
            //       child: Text(
            //         'LOG IN',
            //         style: TextStyle(fontSize: 20, color: Colors.white),
            //       ),
            //     ),
            //   ),
            // ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don`t Remember?'),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => forgetPassword()),
                        );
                      },
                      child: Text('Forget Password'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40.h),

            GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isCreateButtonPressed = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  _isCreateButtonPressed = false;
                });
              },
              onTapCancel: () {
                setState(() {
                  _isCreateButtonPressed = false;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 50.h,
                width: 200.w,
                decoration: BoxDecoration(
                  color: _isCreateButtonPressed ? Color(0xff6C63FF) : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => roleBased()),
                      );
                    },
                    child: Text(
                      'CREATE',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),

            // Container(
            //   height: 40,
            //   width: 200,
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(100),
            //   ),
            //   child: Center(
            //     child: TextButton(
            //       child: Text(
            //         'CREATE',
            //         style: TextStyle(fontSize: 20, color: Colors.black),
            //       ),
            //       onPressed: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(builder: (context) => roleBased()),
            //         );
            //       },
            //     ),
            //   ),
            // ),

            SizedBox(height: 10.h),
            Text(
              'Don`t have an account?',
              style: TextStyle(color: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}