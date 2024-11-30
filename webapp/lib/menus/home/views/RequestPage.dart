import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:webapp/translation_provider.dart';

class RequestPage extends StatelessWidget {
  const RequestPage({super.key});

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'In Progress':
        return Colors.blue;
      case 'Delivery':
        return const Color.fromRGBO(252, 185, 19, 1);
      case 'Completed':
        return Colors.green;
      case 'Canceled':
        return Colors.red;
      default:
        return Colors.grey; // Default color if status is unknown
    }
  }

  String _translateStatus(String status, Locale locale) {
    if (locale.languageCode == 'pt') {
      switch (status) {
        case 'In Progress':
          return 'Em Progresso';
        case 'Delivery':
          return 'Entrega';
        case 'Completed':
          return 'Concluído';
        case 'Canceled':
          return 'Cancelado';
        default:
          return status;
      }
    }
    return status;
  }

  String _translatePayment(String payment, Locale locale) {
    if (locale.languageCode == 'pt') {
      switch (payment) {
        case 'Credit Card':
          return 'Cartão de Crédito';
        case 'Cash':
          return 'Dinheiro';
        default:
          return payment;
      }
    }
    return payment;
  }

  void _upgradeStatus(DocumentSnapshot request) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(request.reference);
      String currentStatus = freshSnap['status'];
      String newStatus;

      switch (currentStatus) {
        case 'In Progress':
          newStatus = 'Delivery';
          break;
        case 'Delivery':
          newStatus = 'Completed';
          break;
        default:
          newStatus = currentStatus;
      }

      transaction.update(freshSnap.reference, {'status': newStatus});
    });
  }

  void _cancelRequest(DocumentSnapshot request) {
    request.reference.update({'status': 'Canceled'});
  }

  void _openGoogleMaps(String address) async {
    try {
      final query = Uri.encodeComponent(address);
      final googleMapsUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$query';

      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Could not open Google Maps';
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userSnapshot.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = Provider.of<TranslationProvider>(context);
    final locale = translationProvider.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(translationProvider.translate('requests')),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
                    translationProvider.translate('no_requests_available')));
          }
          final requests = snapshot.data!.docs;

          // Sort requests by timestamp in descending order
          requests.sort((a, b) {
            Timestamp timestampA = a['timestamp'];
            Timestamp timestampB = b['timestamp'];
            return timestampB.compareTo(timestampA);
          });

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final products = request['products'] as List<dynamic>;
              final productNames = products
                  .map((product) => product['productName'].toString())
                  .toList();

              // Format the timestamp
              final timestamp = request['timestamp'] as Timestamp;
              final formattedTimestamp =
                  DateFormat('HH:mm on dd-MM-yyyy').format(timestamp.toDate());

              // Check the status
              final status = request['status'];

              return FutureBuilder<Map<String, dynamic>>(
                future: _getUserDetails(request['userId']),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!userSnapshot.hasData) {
                    return Center(
                        child: Text(translationProvider
                            .translate('user_details_not_available')));
                  }
                  final user = userSnapshot.data!;
                  final userName = user['name'];
                  final userPhone = user['phone'];

                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${translationProvider.translate('request')}: ${productNames.join(', ')}',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${translationProvider.translate('user')}: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: userName,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${translationProvider.translate('phone')}: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: userPhone,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${translationProvider.translate('timestamp')}: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: formattedTimestamp,
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${translationProvider.translate('address')}: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: request['address'],
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${translationProvider.translate('price')}: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${request['price']}\€',
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${translationProvider.translate('payment')}: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _translatePayment(
                                        request['payment'], locale),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, // Reduced vertical padding
                                    horizontal:
                                        16.0, // Reduced horizontal padding
                                  ),
                                  child: Text(
                                    _translateStatus(status, locale),
                                    style: const TextStyle(
                                      fontSize: 16.0, // Reduced font size
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(
                                            252, 185, 19, 1), // Button color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Same border radius as container
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 8.0), // Reduced padding
                                      ),
                                      onPressed: status == 'Completed' ||
                                              status == 'Canceled'
                                          ? null
                                          : () => _upgradeStatus(request),
                                      child: Text(
                                        translationProvider
                                            .translate('upgrade'),
                                        style: const TextStyle(
                                          fontSize:
                                              12.0, // Reduced font size for the button
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white, // Text color
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red, // Button color
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.0), // Same border radius as container
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal:
                                                16.0), // Reduced padding
                                      ),
                                      onPressed: status == 'Completed' ||
                                              status == 'Canceled'
                                          ? null
                                          : () => _cancelRequest(request),
                                      child: Text(
                                        translationProvider.translate('cancel'),
                                        style: const TextStyle(
                                          fontSize:
                                              16.0, // Reduced font size for the button
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white, // Text color
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.map),
                            color: Colors.blue,
                            iconSize: 32.0,
                            onPressed: () =>
                                _openGoogleMaps(request['address']),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
