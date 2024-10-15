import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimilarProductsScreen extends StatelessWidget {
  final List<dynamic> products;

  SimilarProductsScreen({required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Similar Products'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          var product = products[index];
          return ListTile(
            title: Text(product['Title']),
            subtitle: Text('Price: ${product['Price']}'),
            trailing: Text('SKU: ${product['SKU']}'),
          );
        },
      ),
    );
  }
}