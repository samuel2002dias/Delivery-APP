// ignore_for_file: file_names, use_build_context_synchronously, prefer_const_literals_to_create_immutables, unused_local_variable, unnecessary_cast, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/IngredientsWidget.dart';
import 'package:delivery/menus/home/views/FeedbackPage.dart';
import 'package:delivery/menus/home/views/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:delivery/product/src/firebase_product.dart';
import '../../../firebase_Feedbacks.dart';

class DetailsPage extends StatelessWidget {
  final String productId;

  const DetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final FirebaseProduct _firebaseProduct = FirebaseProduct();
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
        future: _firebaseProduct.getProductDetails(productId),
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
                      height: MediaQuery.of(context).size.width - 190,
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    MyWidget(
                      name: ingredients['ingredientName1'] ?? 'Ingredient 1',
                      icon: FontAwesomeIcons.carrot,
                    ),
                    const SizedBox(width: 8),
                    MyWidget(
                      name: ingredients['ingredientName2'] ?? 'Ingredient 2',
                      icon: FontAwesomeIcons.carrot,
                    ),
                    const SizedBox(width: 8),
                    MyWidget(
                      name: ingredients['ingredientName3'] ?? 'Ingredient 3',
                      icon: FontAwesomeIcons.drumstickBite,
                    ),
                    const SizedBox(width: 8),
                    MyWidget(
                      name: ingredients['ingredientName4'] ?? 'Ingredient 4',
                      icon: FontAwesomeIcons.cheese,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: getFeedbacks(productId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading feedbacks'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No feedbacks found'));
                      }

                      final feedbacks = snapshot.data!;
                      final users = snapshot.data!;

                      return ListView.builder(
                        itemCount: feedbacks.length,
                        itemBuilder: (context, index) {
                          final feedback = feedbacks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    feedback['feedback'] ?? 'No feedback',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'From ${feedback['name']}',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 0),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => FeedbackPage(
                            productId: productId,
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
                      "Feedback",
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
                      await _firebaseProduct.addToCart(
                          context, productId, productData);
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
