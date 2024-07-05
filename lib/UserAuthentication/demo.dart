import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stitchhub_app/Dashboard/Constraints/colors.dart';

class demo extends StatelessWidget {
  const demo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu, color: Colors.black),
        title: Text('StitchHUB', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
              margin: const EdgeInsets.only(right: 20, top: 7),
              // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: tCardByColor),
              child: IconButton(
                  onPressed: () {},
                  icon: const Image(image: AssetImage('assets/user.png')))),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(tDashboardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weolcome to Stitch Hub',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  )),
              Text('Handmade Clothing',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: tDashboardPadding),
              Container(
                decoration: const BoxDecoration(
                    border: Border(left: BorderSide(width: 4))),
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Search...',
                        style: TextStyle(color: Colors.grey.withOpacity(0.5))),
                    const Icon(
                      Icons.mic,
                      size: 25,
                    )
                  ],
                ),
              ),
              SizedBox(height: tDashboardPadding),
              SizedBox(
                height: 45,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(
                      width: 170,
                      height: 50,
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: tDarkColor,
                            ),
                            child: Center(
                              child: Text(
                                'JS',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Java Script',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('10 Lessons'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      height: 50,
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: tDarkColor,
                            ),
                            child: Center(
                              child: Text(
                                'JS',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Java Script',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('10 Lessons'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      height: 50,
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: tDarkColor,
                            ),
                            child: Center(
                              child: Text(
                                'JS',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Java Script',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('10 Lessons'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      height: 50,
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: tDarkColor,
                            ),
                            child: Center(
                              child: Text(
                                'JS',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Java Script',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('10 Lessons'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      height: 50,
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: tDarkColor,
                            ),
                            child: Center(
                              child: Text(
                                'JS',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Java Script',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('10 Lessons'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tDashboardPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: tCardByColor),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(child: Icon(Icons.bookmark)),
                              Flexible(
                                  child: Image(
                                    image: AssetImage('assets/securepass.png'),
                                    height: 80,
                                  )),
                            ],
                          ),
                          SizedBox(height: tDashboardPadding),
                          Text('Android for Beginners',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                          Text('10 Lessions',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: tCardByColor),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(child: Icon(Icons.bookmark)),
                                    Flexible(
                                        child: Image(
                                          image: AssetImage('assets/securepass.png'),
                                          height: 80,
                                        )),
                                  ],
                                ),
                                SizedBox(height: tDashboardPadding),
                                Text('JAVA',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                Text('10 Lessions',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                  onPressed: () {}, child: Text('View All'))),
                        ],
                      )),
                ],
              ),
              SizedBox(height: tDashboardPadding),
              Text('Top Courses',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              SizedBox(
                width: 320,
                height: 200,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: tCardByColor),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "Flutter Crash Course",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Flexible(
                              child: const Image(
                                  image: AssetImage('assets/newpassword.png'),
                                  height: 110))
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: const Icon(Icons.play_arrow),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // decoration: const BoxDecoration(
          //   image: DecorationImage(
          //     image: AssetImage(
          //       'assets/DashboardCover.jpg',
          //     ),
          //     fit: BoxFit.cover,
          //   ),
          // ),
        ),
      ),
    );
  }
}
