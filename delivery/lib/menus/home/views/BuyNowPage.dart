import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/IngredientsWidget.dart';
import 'package:delivery/MapWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BuyNowPage extends StatefulWidget {
  final String productId;

  const BuyNowPage({super.key, required this.productId});

  @override
  _BuyNowPageState createState() => _BuyNowPageState();
}

class _BuyNowPageState extends State<BuyNowPage> {
  LatLng _selectedLocation =
      const LatLng(38.71667, -9.13333); // Default to Lisbon, Portugal
  Map<String, dynamic>? productData;
  String _deliveryStatus = 'In preparation'; // Default status
  final TextEditingController _numberController = TextEditingController();
  final FocusNode _numberFocusNode = FocusNode();
  final TextEditingController _observationsController = TextEditingController();
  final FocusNode _observationsFocusNode = FocusNode();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  @override
  void dispose() {
    _numberFocusNode.dispose();
    _observationsFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('product')
          .doc(widget.productId)
          .get();
      if (snapshot.exists) {
        setState(() {
          productData = snapshot.data() as Map<String, dynamic>?;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  Future<void> _sendLocationToFirebase() async {
    if (productData == null) {
      final snackBar = SnackBar(
        content: Text('Product data is not loaded yet.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('requests').add({
        'productId': widget.productId,
        'productName': productData!['name'],
        'productPrice': productData!['price'],
        'latitude': _selectedLocation.latitude,
        'longitude': _selectedLocation.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'status': _deliveryStatus,
        'nif':
            _numberController.text.isNotEmpty ? _numberController.text : null,
        'observations': _observationsController.text.isNotEmpty
            ? _observationsController.text
            : null,
      });
      final snackBar = SnackBar(
        content: Text(
            'Location and product details sent to Firebase: $_selectedLocation'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Failed to send location and product details: $e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _onLocationSelected(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
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
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (OverscrollIndicatorNotification notification) {
                  return true;
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: productData == null
                      ? const Center(child: Text('Product not found'))
                      : Column(
                          children: [
                            const SizedBox(height: 10),
                            Center(
                              child: SizedBox(
                                width: 300,
                                height: 150,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: InkWell(
                                    onTap: () {},
                                    child: AnimatedContainer(
                                      duration: const Duration(seconds: 0),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade400
                                                .withOpacity(0.5),
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ClipOval(
                                                  child: Image.network(
                                                    productData!['image'],
                                                    height: 130.0,
                                                    width: 130.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        productData!['name'] ??
                                                            'Product Name',
                                                        style: const TextStyle(
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 4.0),
                                                      Text(
                                                        productData![
                                                                'description'] ??
                                                            'Description',
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          color:
                                                              Colors.grey[700],
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
                                                  '\$${productData!['price'] ?? '0.00'}',
                                                  style: const TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                        252, 185, 19, 1),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: (productData!['Ingredients'] ?? [])
                                  .map<Widget>((ingredient) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0),
                                  child: MyWidget(
                                    name: ingredient ?? 'Ingredient',
                                    icon: FontAwesomeIcons.carrot,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Where should the product be delivered?',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            MapWidget(
                              initialLocation: _selectedLocation,
                              onLocationSelected: _onLocationSelected,
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            const SizedBox(height: 5),
                            const Text(
                              ' NIF',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextField(
                              controller: _numberController,
                              focusNode: _numberFocusNode,
                              keyboardType: TextInputType.number,
                              maxLength: 9,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(252, 185, 19, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(252, 185, 19, 1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(252, 185, 19, 1),
                                  ),
                                ),
                                labelText: 'Insert NIF',
                                counterText:
                                    '', // This line removes the digit counter
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                // Handle payment method action
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: const BorderSide(
                                    color: Color.fromRGBO(252, 185, 19, 1),
                                  ),
                                ),
                                minimumSize: const Size.fromHeight(
                                    50), // Match the height of the TextField
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Payment Method',
                                    style: TextStyle(
                                      color: Color.fromRGBO(252, 185, 19, 1),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Color.fromRGBO(252, 185, 19, 1),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                            const Text(
                              'Observations',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _observationsController,
                              focusNode: _observationsFocusNode,
                              keyboardType: TextInputType.text,
                              maxLength: 200,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 20.0),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(252, 185, 19, 1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(252, 185, 19, 1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(252, 185, 19, 1),
                                  ),
                                ),
                                labelText: 'Observations',
                                labelStyle: TextStyle(
                                  color: Color.fromRGBO(252, 185, 19, 1),
                                ),
                                counterText:
                                    '', // This line removes the digit counter
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextButton(
                                  onPressed: _sendLocationToFirebase,
                                  style: TextButton.styleFrom(
                                    elevation: 3.0,
                                    backgroundColor:
                                        const Color.fromRGBO(252, 185, 19, 1),
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
                            ),
                          ],
                        ),
                ),
              ),
      ),
    );
  }
}
