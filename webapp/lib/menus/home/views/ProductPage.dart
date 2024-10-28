import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('product').get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<String> _getImageUrl(String imagePath) async {
    try {
      String downloadURL =
          await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error getting image URL: $e');
      return 'images/Logo.png'; // Fallback image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          } else {
            List<Map<String, dynamic>> products = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var productData = products[index];
                      print(
                          'Product Data: $productData'); // Debug print for product data
                      String imagePath =
                          productData['image'] ?? 'images/Logo.png';
                      print(
                          'Image Path: $imagePath'); // Debug print for image path

                      return FutureBuilder<String>(
                        future: _getImageUrl(imagePath),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            String imageUrl =
                                snapshot.data ?? 'images/Logo.png';
                            print(
                                'Image URL: $imageUrl'); // Debug print for image URL

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: AnimatedContainer(
                                duration: const Duration(
                                    seconds:
                                        1), // Set the duration of the animation
                                curve: Curves
                                    .easeInOut, // Set the curve of the animation
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      25.0), // Set border radius
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
                                height:
                                    150.0, // Specify the height of the container
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
                                              imageUrl,
                                              height:
                                                  130.0, // Adjust the height as needed
                                              width:
                                                  130.0, // Adjust the width as needed
                                              fit: BoxFit
                                                  .cover, // Ensure the image covers the entire area
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                print(
                                                    'Error loading image: $error'); // Debug print for image loading error
                                                print(
                                                    'Stack trace: $stackTrace'); // Debug print for stack trace
                                                return Image.asset(
                                                  'images/Logo.png',
                                                  height: 130.0,
                                                  width: 130.0,
                                                  fit: BoxFit.cover,
                                                );
                                              },
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
                                                  productData['name'] ??
                                                      'Product Name',
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
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Add your edit product logic here
                                          print('Edit product tapped');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(
                                              252, 185, 19, 1), // Button color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                25.0), // Same border radius as container
                                          ),
                                        ),
                                        child: const Text(
                                          'Edit product',
                                          style: TextStyle(
                                            fontSize:
                                                18.0, // Font size for the button
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white, // Text color
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/add-product');
                      print('Add product tapped');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromRGBO(252, 185, 19, 1), // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            25.0), // Same border radius as container
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0), // Increase padding
                    ),
                    child: const Text(
                      'Add Product',
                      style: TextStyle(
                        fontSize: 20.0, // Increase font size for the button
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
