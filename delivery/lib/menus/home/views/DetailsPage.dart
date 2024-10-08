// ignore_for_file: file_names, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/IngredientsWidget.dart';
import 'package:delivery/menus/home/views/BuyNowPage.dart';
import 'package:delivery/menus/home/views/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailsPage extends StatelessWidget {
  final String productId;

  const DetailsPage({super.key, required this.productId});

  Future<DocumentSnapshot> getProductDetails() async {
    return await FirebaseFirestore.instance
        .collection('product')
        .doc(productId)
        .get();
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
            // Pushes the button to the right
          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getProductDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Product not found'));
          }

          final productData = snapshot.data!.data() as Map<String, dynamic>;
          final ingredients =
              productData['ingredients'] as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(3, 3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        30), // Add border radius to the image
                    child: Image.network(
                      productData['image'] ?? 'images/cheese.png',
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width - 40,
                      fit: BoxFit
                          .contain, // Ensure the image covers the container
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(3, 3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 14.0),
                                child: Text(
                                  productData['name'] ?? 'Product Name',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 14.0), // Apply padding only on top
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "\$${productData['price'] ?? '0.00'}",
                                    style: const TextStyle(
                                      color: Color.fromRGBO(252, 185, 19, 1),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    MyWidget(
                      name: ingredients['ingredientName1'] ?? 'Ingredient 1',
                      icon: FontAwesomeIcons.carrot,
                    ),
                    const SizedBox(width: 12),
                    MyWidget(
                      name: ingredients['ingredientName2'] ?? 'Ingredient 2',
                      icon: FontAwesomeIcons.carrot,
                    ),
                    const SizedBox(width: 14),
                    MyWidget(
                      name: ingredients['ingredientName3'] ?? 'Ingredient 3',
                      icon: FontAwesomeIcons.drumstickBite,
                    ),
                    const SizedBox(width: 14),
                    MyWidget(
                      name: ingredients['ingredientName4'] ?? 'Ingredient 4',
                      icon: FontAwesomeIcons.cheese,
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => BuyNowPage(
                            productId: productId,
                            products: [],
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
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: TextButton(
                    onPressed: () async {
                      await addToCart(context, productId, productData);
                      print('Add to Cart button pressed');
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
                      "Add to Cart",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
