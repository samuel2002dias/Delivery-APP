import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:webapp/main.dart';

class FeedbacksGiven extends StatelessWidget {
  final String userID;

  const FeedbacksGiven({super.key, required this.userID});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedbacks Given'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('feedbacks')
                  .where('userId', isEqualTo: userID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No feedback found.'));
                }

                final feedbacks = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = feedbacks[index];
                    final productId = feedback['productId'];

                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          _firestore.collection('product').doc(productId).get(),
                      builder: (context, productSnapshot) {
                        if (productSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!productSnapshot.hasData ||
                            !productSnapshot.data!.exists) {
                          return const ListTile(
                            title: Text('Product not found'),
                          );
                        }

                        final product = productSnapshot.data!;
                        final productName =
                            product['name'] ?? 'No Product Name';
                        final productImage = product['image'] ?? '';

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade400.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 5,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            height: 150.0,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipOval(
                                        child: Image.network(
                                          productImage,
                                          height: 130.0,
                                          width: 130.0,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
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
                                                'Error loading image: $error');
                                            print('Stack trace: $stackTrace');
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
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Feedback given for the $productName',
                                              style: const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              feedback['feedback'] ??
                                                  'No feedback',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                context.go('/home');
                print('Go back tapped');
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
                'Go Back',
                style: TextStyle(
                  fontSize: 20.0, // Increase font size for the button
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Text color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
