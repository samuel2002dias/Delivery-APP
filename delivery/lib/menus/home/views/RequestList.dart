// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:delivery/product/src/firebase_product.dart';
import 'package:provider/provider.dart';
import 'package:delivery/translation_provider.dart';

class RequestList extends StatefulWidget {
  const RequestList({Key? key}) : super(key: key);

  @override
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  late TranslationProvider translationProvider;

  @override
  void initState() {
    super.initState();
    translationProvider =
        Provider.of<TranslationProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final FirebaseProduct _firebaseProduct = FirebaseProduct();
    translationProvider = Provider.of<TranslationProvider>(context);

    if (user == null) {
      return Center(
          child: Text(translationProvider.translate('user_not_signed_in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(translationProvider.translate('your_requests')),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp',
                descending: true) // Order by timestamp in descending order
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(
                child: Text(
                    translationProvider.translate('something_went_wrong')));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('No data found');
            return Center(
                child:
                    Text(translationProvider.translate('no_requests_found')));
          }

          final requests = snapshot.data!.docs;
          print('Requests found: ${requests.length}');

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (BuildContext context, int index) {
              final request = requests[index];
              final requestData = request.data() as Map<String, dynamic>;

              final totalPrice = requestData['price'];
              final products = requestData['products'] as List<dynamic>?;
              final status = requestData['status'];
              final timestamp = requestData['timestamp'] as Timestamp?;

              if (products == null) {
                return const SizedBox.shrink();
              }

              // Get product names, including duplicates based on quantity
              final productNames = products
                  .expand((product) => List.filled(
                      product['quantity'] ?? 1, product['productName']))
                  .join(', ');

              // If there's only one product, fetch its data
              final productId =
                  products.length == 1 ? products[0]['productId'] : null;

              // Format the timestamp to a readable date format
              final formattedDate = timestamp != null
                  ? DateFormat('dd-MM-yyyy - kk:mm').format(timestamp.toDate())
                  : 'N/A';

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          productId != null
                              ? FutureBuilder<Map<String, dynamic>?>(
                                  future: _firebaseProduct
                                      .fetchProductData(productId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        snapshot.data == null) {
                                      return const Icon(Icons.broken_image);
                                    }
                                    final productData = snapshot.data!;
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: Image.network(
                                        productData['image'],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.broken_image);
                                        },
                                      ),
                                    );
                                  },
                                )
                              : const Icon(
                                  CupertinoIcons.bag,
                                  size: 80,
                                  color: Color.fromRGBO(252, 185, 19, 1),
                                ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productNames,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (productId != null)
                                  FutureBuilder<Map<String, dynamic>?>(
                                    future: _firebaseProduct
                                        .fetchProductData(productId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }
                                      if (snapshot.hasError ||
                                          !snapshot.hasData ||
                                          snapshot.data == null) {
                                        return const SizedBox.shrink();
                                      }
                                      final productData = snapshot.data!;
                                      return Text(productData['description']);
                                    },
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                    '${translationProvider.translate('total_price')}: \$${totalPrice ?? 'N/A'}'),
                                Text(
                                    '${translationProvider.translate('date')}: $formattedDate'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _translateStatus(status),
                            style: const TextStyle(color: Colors.white),
                          ),
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
    );
  }

  String _translateStatus(String? status) {
    final translationProvider =
        Provider.of<TranslationProvider>(context, listen: false);
    switch (status) {
      case 'In Progress':
        return translationProvider.translate('in_progress');
      case 'Delivery':
        return translationProvider.translate('delivery');
      case 'Completed':
        return translationProvider.translate('completed');

      default:
        return translationProvider.translate('unknown_status');
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'In Progress':
        return Colors.blue;
      case 'Delivery':
        return const Color.fromRGBO(252, 185, 19, 1);
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey; // Default color if status is unknown
    }
  }
}
