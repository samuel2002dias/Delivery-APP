import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/menus/home/views/HomePage.dart';
import 'package:delivery/product/src/enitities/productEntity.dart';
import 'package:delivery/product/src/models/models.dart';
import 'package:delivery/product/src/productClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseProduct implements ProductClass {
  final productList = FirebaseFirestore.instance.collection('product');
  Future<List<Product>> getProduct() async {
    try {
      return await productList.get().then((value) => value.docs
          .map((e) => Product.fromEntity(ProductEntity.fromJson(e.data())))
          .toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCartProducts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('');
      }

      final userId = user.uid;
      print('Fetching products for user: $userId');
      final querySnapshot =
          await FirebaseFirestore.instance.collection('cart').doc(userId).get();

      if (!querySnapshot.exists) {
        print('No products found in the cart collection for user $userId.');
        return [];
      } else {
        print('Products fetched successfully for user $userId.');
      }

      final cartData = querySnapshot.data() as Map<String, dynamic>;
      final products = List<Map<String, dynamic>>.from(cartData['products']);

      return products;
    } catch (e) {
      print('Error fetching cart products: $e');
      rethrow;
    }
  }

  Future<void> addToCart(BuildContext context, String productId,
      Map<String, dynamic> productData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartRef =
          FirebaseFirestore.instance.collection('cart').doc(user.uid);
      final cartSnapshot = await cartRef.get();

      if (cartSnapshot.exists) {
        // If the cart already exists, update it
        final cartData = cartSnapshot.data() as Map<String, dynamic>;
        final products = cartData['products'] as List<dynamic>;
        final productIndex =
            products.indexWhere((product) => product['id'] == productId);

        if (productIndex >= 0) {
          // If the product already exists in the cart, increment its quantity
          products[productIndex]['quantity'] += 1;
        } else {
          // If the product does not exist in the cart, add it with quantity 1
          products.add({
            'id': productId,
            'data': productData,
            'quantity': 1,
          });
        }
        await cartRef.update({'products': products});
      } else {
        // If the cart does not exist, create it with the product
        await cartRef.set({
          'products': [
            {
              'id': productId,
              'data': productData,
              'quantity': 1,
            }
          ]
        });
      }

      // Navigate back to the home page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const HomePage(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      print('User not signed in');
    }
  }

  Future<void> addToCartDirect(
      String productId, Map<String, dynamic> productData, int quantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartRef =
          FirebaseFirestore.instance.collection('cart').doc(user.uid);
      final cartSnapshot = await cartRef.get();

      if (cartSnapshot.exists) {
        // If the cart already exists, update it
        final cartData = cartSnapshot.data() as Map<String, dynamic>;
        final products = List<Map<String, dynamic>>.from(cartData['products']);
        final productIndex =
            products.indexWhere((product) => product['id'] == productId);

        if (productIndex >= 0) {
          // If the product already exists in the cart, increment its quantity
          products[productIndex]['quantity'] += quantity;
        } else {
          // If the product does not exist in the cart, add it with the specified quantity
          products.add({
            'id': productId,
            'data': productData,
            'quantity': quantity,
          });
        }

        await cartRef.update({'products': products});
      } else {
        // If the cart does not exist, create it with the product
        await cartRef.set({
          'products': [
            {
              'id': productId,
              'data': productData,
              'quantity': quantity,
            }
          ]
        });
      }
    } else {
      print('User not signed in');
    }
  }

  Future<DocumentSnapshot> getProductDetails(String productId) async {
    return await FirebaseFirestore.instance
        .collection('product')
        .doc(productId)
        .get();
  }

  Future<Map<String, dynamic>?> fetchProductData(String productId) async {
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('product')
          .doc(productId)
          .get();
      if (productDoc.exists) {
        return productDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error fetching product data: $e');
    }
    return null;
  }
}
