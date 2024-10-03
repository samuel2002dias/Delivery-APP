// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BuyNowPage extends StatelessWidget {
  final String productId;

  const BuyNowPage({super.key, required this.productId});

  Future<DocumentSnapshot> getProductDetails() async {
    return await FirebaseFirestore.instance
        .collection('product')
        .doc(productId)
        .get();
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

          return Padding(
            padding: const EdgeInsets.all(8.0), // Set padding as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* Text(
                  'You are buying:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),*/
                const SizedBox(height: 10), // Space between text and InkWell
                Center(
                  child: SizedBox(
                    width: 300, // Set the width of the InkWell
                    height: 150, // Set the height of the InkWell
                    child: InkWell(
                      onTap: () {},
                      child: AnimatedContainer(
                        duration: const Duration(
                            seconds: 0), // Set the duration of the animation
                        curve:
                            Curves.easeInOut, // Set the curve of the animation
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(25.0), // Set border radius
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade400.withOpacity(
                                  0.5), // Shadow color with opacity
                              spreadRadius: 3, // Spread radius
                              blurRadius: 5, // Blur radius
                              offset: const Offset(
                                  2, 2), // Offset in x and y direction
                            ),
                          ],
                        ),
                        height: 150.0, // Specify the height of the container
                        width: double
                            .infinity, // Make the container take the full width
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(
                                      8.0), // Padding around the image
                                  child: ClipOval(
                                    child: Image.network(
                                      productData['image'] ??
                                          'images/cheese.png',
                                      height:
                                          130.0, // Adjust the height as needed
                                      width:
                                          130.0, // Adjust the width as needed
                                      fit: BoxFit
                                          .cover, // Ensure the image covers the entire area
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        8.0), // Padding around the text
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          productData['name'] ?? 'Product Name',
                                          style: const TextStyle(
                                            fontSize:
                                                20.0, // Larger font size for the name
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                            height:
                                                4.0), // Space between name and ingredients
                                        Text(
                                          productData['description'] ??
                                              'Description',
                                          style: TextStyle(
                                            fontSize:
                                                16.0, // Smaller font size for the ingredients
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 8.0,
                              right: 8.0,
                              child: Row(
                                children: [
                                  Text(
                                    '\$${productData['price'] ?? '0.00'}',
                                    style: const TextStyle(
                                      fontSize: 18.0, // Font size for the price
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(252, 185, 19,
                                          1), // Color for the price
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 8), // Space between price and icon
                                ],
                              ),
                            ),
                          ],
                        ),
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
