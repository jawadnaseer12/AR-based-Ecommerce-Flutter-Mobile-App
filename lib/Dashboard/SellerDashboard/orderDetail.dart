import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderManagement {

  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<int> getPendingOrderCountForCurrentUser() async {

    if (currentUser != null) {
      String? userId = currentUser?.email;

      QuerySnapshot pendingOrderSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('order')
          .get();

      return pendingOrderSnapshot.size;
    } else {
      return 0;
    }
  }

  Future<int> getReturnOrderCountForCurrentUser() async {

    if (currentUser != null) {
      String? userId = currentUser?.email;

      QuerySnapshot returnOrderSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('return order')
          .get();

      return returnOrderSnapshot.size;
    } else {
      return 0;
    }
  }

  Future<int> getShippedOrderCountForCurrentUser() async {

    if (currentUser != null) {
      String? userId = currentUser?.email;

      QuerySnapshot shippedOrderSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('shipped order')
          .get();

      return shippedOrderSnapshot.size;
    } else {
      return 0;
    }
  }

  Future<int> getDeliveredOrderCountForCurrentUser() async {

    if (currentUser != null) {
      String? userId = currentUser?.email;

      QuerySnapshot deliveredOrderSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(userId)
          .collection('deliver order')
          .get();

      return deliveredOrderSnapshot.size;
    } else {
      return 0;
    }
  }

}