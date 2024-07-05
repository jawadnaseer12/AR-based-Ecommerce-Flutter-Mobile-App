import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductManagement {

  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<int> getActiveProductCountForCurrentUser() async {

    if (currentUser != null) {
      String? userId = currentUser?.email;

      QuerySnapshot activeProductsSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('active product')
          .get();

      return activeProductsSnapshot.size;
    } else {
      return 0;
    }
  }

  Future<int> getDraftProductCountForCurrentUser() async {

    if (currentUser != null) {
      String? userId = currentUser?.email;

      QuerySnapshot draftProductsSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('draft product')
          .get();

      return draftProductsSnapshot.size;
    } else {
      return 0;
    }
  }

  Future<int> getDeActiveProductCountForCurrentUser() async {

    if (currentUser != null) {
      String? userId = currentUser?.email;

      QuerySnapshot deActiveProductsSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('deActive product')
          .get();

      return deActiveProductsSnapshot.size;
    } else {
      return 0;
    }
  }

  Future<int> getDeleteProductCountForCurrentUser() async {

    if (currentUser != null) {
      String? userId = currentUser?.email;

      QuerySnapshot deleteProductsSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('delete product')
          .get();

      return deleteProductsSnapshot.size;
    } else {
      return 0;
    }
  }

}