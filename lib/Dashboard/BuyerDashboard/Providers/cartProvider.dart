import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class cartProvider with ChangeNotifier {

  int _cartCount = 0;

  int get cartCount => _cartCount;

  Future<void> fetchCartCount() async {

    User? user = FirebaseAuth.instance.currentUser;
    String? userCartId = user?.email;

    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('buyers')
        .doc(userCartId)
        .collection('cart')
        .get();

    _cartCount = cartSnapshot.docs.length;
    notifyListeners();
  }

  void incrementCartCount() {

    _cartCount++;
    notifyListeners();

  }

  void decrementCartCount() {
    if(_cartCount > 0) {

      _cartCount--;
      notifyListeners();

    }
  }

}