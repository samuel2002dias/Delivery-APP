// ignore_for_file: file_names

import 'package:delivery/ProductCard.dart';
import 'package:delivery/menus/home/views/CreditCardPayment.dart';
import 'package:delivery/menus/home/bloc/Firebase_BuyNow.dart';
import 'package:delivery/menus/home/views/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class BuyNowPage extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic>? singleProduct;

  const BuyNowPage({
    Key? key,
    required this.products,
    this.singleProduct,
    required String productId,
  }) : super(key: key);

  @override
  _BuyNowPageState createState() => _BuyNowPageState();
}

class _BuyNowPageState extends State<BuyNowPage> {
  LatLng _selectedLocation =
      const LatLng(38.71667, -9.13333); // Default to Lisbon, Portugal
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isPaymentOnDelivery = false; // Add this state variable

  @override
  void dispose() {
    _numberController.dispose();
    _observationsController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (message == 'Order requested') {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => HomePage(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsToShow = widget.singleProduct != null
        ? [widget.singleProduct!]
        : widget.products;

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
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification notification) {
            return true;
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                ...productsToShow.map((product) {
                  final productDetails =
                      product['data'] as Map<String, dynamic>;
                  final quantity = product['quantity'] ?? 1;
                  return ProductCard(
                    productDetails: productDetails,
                    quantity: quantity, onTap: () {  },
                  );
                }).toList(),
                const Divider(),
                const SizedBox(height: 5),
                const Text(
                  'Where should the product be delivered?',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  keyboardType: TextInputType.text,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
                    labelText: 'Address',
                    labelStyle: TextStyle(
                      color: Color.fromRGBO(252, 185, 19, 1),
                    ),
                    counterText: '', // This line removes the digit counter
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      onPinPointLocation(
                        context: context,
                        onLocationSelected: (LatLng location) {
                          setState(() {
                            _selectedLocation = location;
                          });
                        },
                        addressController: _addressController,
                      );
                    },
                    child: const Text(
                      'Rather pin point your location? Click here',
                      style: TextStyle(
                        color: Color.fromRGBO(252, 185, 19, 1),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
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
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
                    labelText: 'Insert NIF',
                    counterText: '', // This line removes the digit counter
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isPaymentOnDelivery = !_isPaymentOnDelivery;
                    });
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
                  child: Center(
                    child: Text(
                      _isPaymentOnDelivery
                          ? 'Payment on Delivery chosen'
                          : 'Payment on Delivery?',
                      style: TextStyle(
                        color: _isPaymentOnDelivery
                            ? Colors.green
                            : Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
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
                  keyboardType: TextInputType.text,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
                    labelText: 'Observations',
                    labelStyle: TextStyle(
                      color: Color.fromRGBO(252, 185, 19, 1),
                    ),
                    counterText: '', // This line removes the digit counter
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextButton(
                        onPressed: () {
                          if (_isPaymentOnDelivery) {
                            for (var product in productsToShow) {
                              sendLocationToFirebase(
                                context: context,
                                productId: product['id'],
                                productData: product['data'],
                                numberController: _numberController,
                                observationsController: _observationsController,
                                addressController: _addressController,
                                selectedLocation: _selectedLocation,
                                showDialog: _showDialog,
                                paymentMethod: 'Payment on Delivery',
                              );
                            }
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CreditCardPayment(),
                              ),
                            );
                          }
                        },
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
                          "Pay Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
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
