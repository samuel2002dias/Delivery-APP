// ignore_for_file: sort_child_properties_last

import 'package:flutter/cupertino.dart';
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

  Future<void> _Product(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('product')
          .doc(productId)
          .delete();
    } catch (e) {
      print('Error removing product: $e');
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _Product(productId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Page'),
      ),
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
                      String imagePath =
                          productData['image'] ?? 'images/Logo.png';

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

                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: isLargeScreen ? 32.0 : 16.0),
                              child: AnimatedContainer(
                                duration: const Duration(seconds: 1),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.grey.shade400.withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                height: isLargeScreen
                                    ? 170.0
                                    : 186.0, // Adjusted height
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ClipOval(
                                            child: Image.network(
                                              imageUrl,
                                              height:
                                                  isLargeScreen ? 100.0 : 100.0,
                                              width:
                                                  isLargeScreen ? 100.0 : 100.0,
                                              fit: BoxFit.cover,
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
                                                return Image.asset(
                                                  'images/Logo.png',
                                                  height: isLargeScreen
                                                      ? 150.0
                                                      : 130.0,
                                                  width: isLargeScreen
                                                      ? 150.0
                                                      : 130.0,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  productData['name'] ??
                                                      'Product Name',
                                                  style: TextStyle(
                                                    fontSize: isLargeScreen
                                                        ? 24.0
                                                        : 20.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  productData['description'] ??
                                                      'Description',
                                                  style: TextStyle(
                                                    fontSize: isLargeScreen
                                                        ? 18.0
                                                        : 16.0,
                                                    color: Colors.grey[700],
                                                  ),
                                                  maxLines:
                                                      isLargeScreen ? null : 1,
                                                  overflow: isLargeScreen
                                                      ? TextOverflow.visible
                                                      : TextOverflow.ellipsis,
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
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              context.go(
                                                  '/edit-product/${productData['productID']}');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      252, 185, 19, 1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical:
                                                    isLargeScreen ? 12.0 : 8.0,
                                                horizontal:
                                                    isLargeScreen ? 24.0 : 16.0,
                                              ),
                                            ),
                                            child: Text(
                                              'Edit',
                                              style: TextStyle(
                                                fontSize:
                                                    isLargeScreen ? 20.0 : 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          ElevatedButton(
                                            onPressed: () {
                                              _showDeleteConfirmationDialog(
                                                  context,
                                                  productData['productID']);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical:
                                                    isLargeScreen ? 12.0 : 8.0,
                                                horizontal:
                                                    isLargeScreen ? 24.0 : 16.0,
                                              ),
                                            ),
                                            child: Text(
                                              'Remove',
                                              style: TextStyle(
                                                fontSize:
                                                    isLargeScreen ? 20.0 : 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
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
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(252, 185, 19, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: isLargeScreen ? 20.0 : 16.0,
                          horizontal: isLargeScreen ? 40.0 : 32.0),
                    ),
                    child: Text(
                      'Add Product',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 22.0 : 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/addImage');
        },
        child: const Icon(CupertinoIcons.photo_camera, color: Colors.white),
        backgroundColor: const Color.fromRGBO(252, 185, 19, 1),
      ),
    );
  }
}
