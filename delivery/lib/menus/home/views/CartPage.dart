// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:delivery/menus/home/views/BuyNowPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:delivery/product/src/firebase_product.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseProduct _firebaseProduct = FirebaseProduct();
  late Future<List<Map<String, dynamic>>> _cartProductsFuture;

  @override
  void initState() {
    super.initState();
    _cartProductsFuture = _firebaseProduct.fetchCartProducts();
  }

  Future<void> _removeProductFromCart(String productId, int quantity) async {
    try {
      await _firebaseProduct.removeProductFromCart(productId, quantity);

      // Update the state to reflect the changes
      setState(() {
        _cartProductsFuture = _firebaseProduct.fetchCartProducts();
      });
    } catch (e) {
      print('Error removing product from cart: $e');
      rethrow;
    }
  }

  Future<void> _removeAllProductsFromCart() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      final userId = user.uid;
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(userId);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'hasCart': false});

      await cartRef.update({'products': []});
      print('All products removed successfully.');

      setState(() {
        _cartProductsFuture = _firebaseProduct.fetchCartProducts();
      });
    } catch (e) {
      print('Error removing all products from cart: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Center(
              child: Image.asset(
                'images/Logo.png',
                height: 70,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Cart',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _cartProductsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No products in cart.'));
                    }

                    final products = snapshot.data!;
                    return SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final productData = products[index];
                          final productDetails =
                              productData['data'] as Map<String, dynamic>;
                          final productId = productData['id'];
                          final quantity = productData['quantity'] ?? 1;
                          print('Rendering product: $productData');
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              leading: ClipOval(
                                child: Image.network(
                                  productDetails['image'] ??
                                      'images/cheese.png',
                                  height: 50.0,
                                  width: 50.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                productDetails['name'] ?? 'Product Name',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productDetails['description'] ??
                                        'Description',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    'Quantity: $quantity',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () async {
                                      await _removeProductFromCart(
                                          productId, quantity);
                                    },
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '\$${productDetails['price'] ?? '0.00'}',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(252, 185, 19, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _cartProductsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text(''));
                  }

                  final products = snapshot.data!;
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => BuyNowPage(
                              products: products,
                              productId: '',
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        elevation: 3.0,
                        backgroundColor: const Color.fromRGBO(252, 185, 19, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Buy Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Positioned(
            bottom: 60,
            right: 16,
            child: FloatingActionButton(
              onPressed: _removeAllProductsFromCart,
              backgroundColor: const Color.fromRGBO(252, 185, 19, 1),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
