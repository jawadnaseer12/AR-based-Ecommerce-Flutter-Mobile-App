import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/addProduct.dart';
import 'package:stitchhub_app/Dashboard/SellerDashboard/sellerDashboard.dart';

class productSuccessfullyListed extends StatelessWidget {
  const productSuccessfullyListed({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/double-check.gif'),
                  alignment: Alignment.center,
                  height: 250.h,
                  width: 250.h,
                ),
                SizedBox(height: 10.h),
                Text('Product Successfully Listed', style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),),
                SizedBox(height: 40.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 50.h,
                      width: 130.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: TextButton(
                          child: Text(
                            'Add Product',
                            style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => addProduct()));
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 10.h),
                    Container(
                      height: 50.h,
                      width: 130.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: TextButton(
                          child: Text(
                            'Cancel',
                            style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => sellerDashboard()));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
