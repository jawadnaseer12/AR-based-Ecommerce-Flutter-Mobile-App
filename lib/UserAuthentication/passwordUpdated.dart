import 'package:flutter/material.dart';
import 'package:stitchhub_app/UserAuthentication/login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class passwordUpdated extends StatelessWidget {
  const passwordUpdated({super.key});

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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Successfully Updated', style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),),
              Text('Your password has been changed',
              style: TextStyle(fontSize: 15, color: Colors.white,),),
              Image(
                image: AssetImage('assets/success.png'),
                alignment: Alignment.center,
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
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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
    );
  }
}
