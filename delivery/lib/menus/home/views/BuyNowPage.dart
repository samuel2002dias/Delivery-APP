import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/IngredientsWidget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BuyNowPage extends StatefulWidget {
  final String productId;

  const BuyNowPage({super.key, required this.productId});

  @override
  _BuyNowPageState createState() => _BuyNowPageState();
}

class _BuyNowPageState extends State<BuyNowPage> {
  late GoogleMapController mapController;
  LatLng _selectedLocation =
      const LatLng(38.71667, -9.13333); // Default to Lisbon, Portugal
  late Map<String, dynamic> productData;
  String _deliveryStatus = 'In preparation'; // Default status

  Future<DocumentSnapshot> getProductDetails() async {
    return await FirebaseFirestore.instance
        .collection('product')
        .doc(widget.productId)
        .get();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  Future<void> _sendLocationToFirebase() async {
    try {
      await FirebaseFirestore.instance.collection('requests').add({
        'productId': widget.productId,
        'productName': productData['name'],
        'productPrice': productData['price'],
        'latitude': _selectedLocation.latitude,
        'longitude': _selectedLocation.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'status': _deliveryStatus, // Add the delivery status
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

          productData = snapshot.data!.data() as Map<String, dynamic>;

          List<dynamic> ingredients = productData['Ingredients'] ?? [];

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: SizedBox(
                        width: 300,
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 10.0), // Add padding here
                          child: InkWell(
                            onTap: () {},
                            child: AnimatedContainer(
                              duration: const Duration(seconds: 0),
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
                                            productData['image'],
                                            height: 130.0,
                                            width: 130.0,
                                            fit: BoxFit.cover,
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
                                                style: const TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                productData['description'] ??
                                                    'Description',
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
                                  Positioned(
                                    bottom: 8.0,
                                    right: 8.0,
                                    child: Row(
                                      children: [
                                        Text(
                                          '\$${productData['price'] ?? '0.00'}',
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(252, 185, 19, 1),
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ingredients.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: MyWidget(
                            name: ingredient ?? 'Ingredient',
                            icon: FontAwesomeIcons
                                .carrot, // Adjust the icon as needed
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Where should the product be delivered?',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 300, // Set the desired width for the map
                        height: 200, // Set the desired height for the map
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey, // Border color
                            width: 2.0, // Border width
                          ),
                          borderRadius:
                              BorderRadius.circular(10.0), // Border radius
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10.0), // Clip the map to the border radius
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: _selectedLocation,
                              zoom: 10.0,
                            ),
                            onTap: _onTap,
                            markers: {
                              Marker(
                                markerId: const MarkerId('selected-location'),
                                position: _selectedLocation,
                              ),
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
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
                      backgroundColor: const Color.fromRGBO(252, 185, 19, 1),
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
          );
        },
      ),
    );
  }
}
