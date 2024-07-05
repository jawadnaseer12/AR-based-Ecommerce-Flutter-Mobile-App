import 'package:flutter/material.dart';
import 'package:stitchhub_app/UserAuthentication/buyerContinueWith.dart';
import 'package:stitchhub_app/UserAuthentication/sellerRegister.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class roleBased extends StatelessWidget {
  const roleBased({super.key});

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
              Image(image: AssetImage('assets/shopnow.png'), height: 340),
              Container(
                height: 50.h,
                width: 200.w,
                decoration: BoxDecoration(
                  color: Color(0xff6C63FF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: TextButton(
                    child: Text(
                      'ARE YOU BUYER?',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => buyerContinueWith()),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                height: 50.h,
                width: 200.w,
                decoration: BoxDecoration(
                  color: Color(0xff6C63FF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: TextButton(
                    child: Text(
                      'ARE YOU SELLER?',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => sellerRegister()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
