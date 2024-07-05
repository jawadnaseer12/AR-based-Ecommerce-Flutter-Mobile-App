import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:stitchhub_app/Dashboard/imagePicker.dart';

class profileChange extends StatefulWidget {
  const profileChange({super.key});

  @override
  State<profileChange> createState() => _profileChangeState();
}

class _profileChangeState extends State<profileChange> {

  Uint8List? _storeImage;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);

    try {
      if(img != null) {
        setState(() {
          _storeImage = img;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image Successfully Uploaded!'),
            ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select an image file.'),
            ));
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image.'),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.email;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {Navigator.of(context).pop();}, icon: Icon(Icons.navigate_before)),
          title: Center(child: Text('Profile Picture ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 5, top: 7),
              // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: tCardByColor),
              child: IconButton(
                onPressed: () {},
                icon: Tooltip(
                  message: 'Select Image',
                  child: Icon(Icons.help),
                ),
              ),
            )
          ],
        ),
        body: Center(child: Container(
          child: Column(
            children: [
              SizedBox(height: 200),
              Stack(
                children: [
                  _storeImage != null ?
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: MemoryImage(_storeImage!),
                  )
                      : CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://as2.ftcdn.net/v2/jpg/05/49/98/39/1000_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'),
                  ),
                  Positioned(
                    child: IconButton(
                      onPressed: () {
                        selectImage();
                      },
                      icon: Icon(Icons.add_a_photo, size: 20),
                    ),
                    bottom: -12,
                    left: 60,
                  )
                ],
              ),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 70),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  child: TextFormField(
                    // controller: _fullnameController,
                    decoration: InputDecoration(
                      hintText: 'Edit Name',
                      hintStyle: TextStyle(fontSize: 15),
                      prefixIcon: Icon(Icons.person),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(50)
                      ),
                    ),
                    // validator: (value) => _validateName(value!),
                    onChanged: (value) {
                      setState(() {
                        // fullName = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}