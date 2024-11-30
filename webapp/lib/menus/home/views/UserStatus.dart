import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webapp/translation_provider.dart';


class FeedbacksGiven extends StatelessWidget {
  final String userID;

  const FeedbacksGiven({super.key, required this.userID});

  Future<Map<String, dynamic>> _fetchRequestData() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final QuerySnapshot requestSnapshot = await _firestore
        .collection('requests')
        .where('userId', isEqualTo: userID)
        .get();

    int totalRequests = requestSnapshot.docs.length;
    int completedRequests = 0;
    int canceledRequests = 0;
    double totalMoneySpent = 0.0;
    int completedCreditCardPayments = 0;
    int completedOnDeliveryPayments = 0;

    for (var doc in requestSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'];
      final paymentMethod = data['payment'];
      final amount = data['price'] ?? 0.0;

      if (status == 'Completed') {
        completedRequests++;
        totalMoneySpent += amount;

        if (paymentMethod == 'Credit Card') {
          completedCreditCardPayments++;
        } else if (paymentMethod == 'Payment on Delivery') {
          completedOnDeliveryPayments++;
        }
      } else if (status == 'Canceled') {
        canceledRequests++;
      }
    }

    return {
      'totalRequests': totalRequests,
      'completedRequests': completedRequests,
      'canceledRequests': canceledRequests,
      'totalMoneySpent': totalMoneySpent,
      'completedCreditCardPayments': completedCreditCardPayments,
      'completedOnDeliveryPayments': completedOnDeliveryPayments,
    };
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final translationProvider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translationProvider.translate('feedbacks_given')),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchRequestData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text(translationProvider
                    .translate('error_fetching_request_data')));
          }

          if (!snapshot.hasData) {
            return Center(
                child: Text(
                    translationProvider.translate('no_request_data_found')));
          }

          final requestData = snapshot.data!;
          final totalRequests = requestData['totalRequests'];
          final completedRequests = requestData['completedRequests'];
          final canceledRequests = requestData['canceledRequests'];
          final totalMoneySpent = requestData['totalMoneySpent'];
          final completedCreditCardPayments =
              requestData['completedCreditCardPayments'];
          final completedOnDeliveryPayments =
              requestData['completedOnDeliveryPayments'];

          return Column(
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
                      return Center(
                        child: Text(translationProvider
                            .translate('no_feedbacks_given')),
                      );
                    }

                    final feedbacks = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: feedbacks.length,
                      itemBuilder: (context, index) {
                        final feedback = feedbacks[index];
                        final productId = feedback['productId'];

                        return FutureBuilder<DocumentSnapshot>(
                          future: _firestore
                              .collection('product')
                              .doc(productId)
                              .get(),
                          builder: (context, productSnapshot) {
                            if (productSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!productSnapshot.hasData ||
                                !productSnapshot.data!.exists) {
                              return ListTile(
                                title: Text(translationProvider
                                    .translate('product_not_found')),
                              );
                            }

                            final product = productSnapshot.data!;
                            final productName = product['name'] ??
                                translationProvider
                                    .translate('no_product_name');
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
                                      color:
                                          Colors.grey.shade400.withOpacity(0.5),
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
                                                  translationProvider.translate(
                                                          'feedback_given_for') +
                                                      ' $productName',
                                                  style: const TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  feedback['feedback'] ??
                                                      translationProvider
                                                          .translate(
                                                              'no_feedback'),
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
              const Divider(), // Add this line to separate feedbacks from stats
              if (snapshot.hasData) ...[
                Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(16.0),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${translationProvider.translate('total_requests')}: $totalRequests',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${translationProvider.translate('completed_requests')}: $completedRequests',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${translationProvider.translate('canceled_requests')}: $canceledRequests',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${translationProvider.translate('total_money_spent')}: ${totalMoneySpent.toStringAsFixed(2)}\€',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${translationProvider.translate('completed_credit_card_payments')}: $completedCreditCardPayments',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${translationProvider.translate('completed_on_delivery_payments')}: $completedOnDeliveryPayments',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
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
                  child: Text(
                    translationProvider.translate('go_back'),
                    style: const TextStyle(
                      fontSize: 20.0, // Increase font size for the button
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
