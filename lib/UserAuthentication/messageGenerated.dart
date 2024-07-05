import 'package:flutter/material.dart';
import 'package:stitchhub_app/UserAuthentication/login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class messageGenerated extends StatelessWidget {
  const messageGenerated({super.key});

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
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 150.h),
                Image(image: AssetImage('accountCreated.gif')),
                SizedBox(height: 150.h),
                Text(
                  'Your Account has been',
                  style: TextStyle(
                      fontSize: 25,
                      // fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  'Created Successfully',
                  style: TextStyle(
                      fontSize: 25,
                      // fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 150.h),
                Container(
                  height: 40.h,
                  width: 300.w,
                  decoration: BoxDecoration(
                    color: Color(0xff6C63FF),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: TextButton(
                      child: Text(
                        'BACK TO LOG IN',
                        style:
                        TextStyle(fontSize: 15, /*fontWeight: FontWeight.bold,*/ color: Colors.white),
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
}
