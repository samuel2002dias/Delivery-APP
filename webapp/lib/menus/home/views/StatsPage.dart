import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  DateTime? _selectedDate;
  double _totalAmount = 0.0;
  bool _isLoading = false;
  int _totalRequests = 0;
  int _completedRequests = 0;
  int _canceledRequests = 0;
  String _mostRequestedProduct = '';
  double _averageRequestAmount = 0.0;
  double _completedRequestsPercentage = 0.0;
  double _canceledRequestsPercentage = 0.0;
  int _totalProductsRequested = 0;
  String _mostFrequentRequestTime = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fetchTotalAmount();
  }

  Future<void> _fetchTotalAmount() async {
    if (_selectedDate == null) return;

    setState(() {
      _isLoading = true;
    });

    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(_selectedDate!);

    final QuerySnapshot snapshot =
        await _firestore.collection('requests').get();

    double totalAmount = 0.0;
    int totalRequests = 0;
    int completedRequests = 0;
    int canceledRequests = 0;
    int totalProductsRequested = 0;
    Map<String, int> productRequestCount = {};
    Map<int, int> requestTimeCount = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['timestamp'] as Timestamp;
      final DateTime requestDate = timestamp.toDate();
      final String requestFormattedDate = formatter.format(requestDate);

      if (requestFormattedDate == formattedDate) {
        totalRequests++;
        final amount = data['price'] ?? 0.0;
        totalAmount += amount;

        if (data['status'] == 'Completed') {
          completedRequests++;
        } else if (data['status'] == 'Canceled') {
          canceledRequests++;
        }

        final List<dynamic> products = data['products'] ?? [];
        totalProductsRequested += products.length;
        for (var product in products) {
          final productId = product['productName'] ?? '';
          if (productId.isNotEmpty) {
            if (productRequestCount.containsKey(productId)) {
              productRequestCount[productId] =
                  productRequestCount[productId]! + 1;
            } else {
              productRequestCount[productId] = 1;
            }
          }
        }

        final int requestHour = requestDate.hour;
        if (requestTimeCount.containsKey(requestHour)) {
          requestTimeCount[requestHour] = requestTimeCount[requestHour]! + 1;
        } else {
          requestTimeCount[requestHour] = 1;
        }
      }
    }

    String mostRequestedProduct = '';
    int maxRequests = 0;
    for (var entry in productRequestCount.entries) {
      if (entry.value > maxRequests) {
        maxRequests = entry.value;
        mostRequestedProduct = entry.key;
      }
    }

    if (mostRequestedProduct.isNotEmpty) {
      final DocumentSnapshot productSnapshot = await _firestore
          .collection('products')
          .doc(mostRequestedProduct)
          .get();
      if (productSnapshot.exists) {
        final productData = productSnapshot.data() as Map<String, dynamic>;
        mostRequestedProduct = productData['name'] ?? 'Unknown Product';
      }
    }

    int maxRequestTimeCount = 0;
    int mostFrequentRequestHour = 0;
    for (var entry in requestTimeCount.entries) {
      if (entry.value > maxRequestTimeCount) {
        maxRequestTimeCount = entry.value;
        mostFrequentRequestHour = entry.key;
      }
    }
    final String mostFrequentRequestTime =
        DateFormat.j().format(DateTime(0, 0, 0, mostFrequentRequestHour));

    setState(() {
      _totalAmount = totalAmount;
      _totalRequests = totalRequests;
      _completedRequests = completedRequests;
      _canceledRequests = canceledRequests;
      _mostRequestedProduct = mostRequestedProduct;
      _averageRequestAmount =
          totalRequests > 0 ? totalAmount / totalRequests : 0.0;
      _completedRequestsPercentage =
          totalRequests > 0 ? (completedRequests / totalRequests) * 100 : 0.0;
      _canceledRequestsPercentage =
          totalRequests > 0 ? (canceledRequests / totalRequests) * 100 : 0.0;
      _totalProductsRequested = totalProductsRequested;
      _mostFrequentRequestTime = mostFrequentRequestTime;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2101),
                focusedDay: _selectedDate ?? DateTime.now(),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                  });
                  _fetchTotalAmount();
                },
              ),
              const SizedBox(height: 16.0),
              const Divider(), // Added divider here
              const SizedBox(height: 16.0),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount: \$${_totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Total Requests: $_totalRequests',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Completed Requests: $_completedRequests',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Canceled Requests: $_canceledRequests',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Most Requested Product: $_mostRequestedProduct',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8.0),
                            Text(
                              'Average Request Amount: \$${_averageRequestAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Completed Requests Percentage: ${_completedRequestsPercentage.toStringAsFixed(2)}%',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Canceled Requests Percentage: ${_canceledRequestsPercentage.toStringAsFixed(2)}%',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Total Products Requested: $_totalProductsRequested',
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Most Frequent Request Time: $_mostFrequentRequestTime',
                              style: const TextStyle(fontSize: 16.0),
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
      ),
    );
  }
}
