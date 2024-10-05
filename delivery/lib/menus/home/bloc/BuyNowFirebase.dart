import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class BuyNowFirebase {
  final String productId;
  final TextEditingController numberController;
  final TextEditingController observationsController;
  final String deliveryStatus;
  final LatLng selectedLocation;
  final BuildContext context;

  BuyNowFirebase({
    required this.productId,
    required this.numberController,
    required this.observationsController,
    required this.deliveryStatus,
    required this.selectedLocation,
    required this.context,
  });

  Future<void> loadProductDetails(
      Function(Map<String, dynamic>?) onProductDataLoaded,
      Function(bool) onLoadingStateChanged) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('product')
          .doc(productId)
          .get();
      if (snapshot.exists) {
        onProductDataLoaded(snapshot.data() as Map<String, dynamic>?);
        onLoadingStateChanged(false);
      } else {
        onLoadingStateChanged(false);
      }
    } catch (e) {
      onLoadingStateChanged(false);
      // Handle error
    }
  }

  Future<void> sendLocationToFirebase(Map<String, dynamic>? productData) async {
    if (productData == null) {
      final snackBar = SnackBar(
        content: Text('Product data is not loaded yet.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('requests').add({
        'productId': productId,
        'productName': productData['name'],
        'productPrice': productData['price'],
        'latitude': selectedLocation.latitude,
        'longitude': selectedLocation.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'status': deliveryStatus,
        'nif': numberController.text.isNotEmpty ? numberController.text : null,
        'observations': observationsController.text.isNotEmpty
            ? observationsController.text
            : null,
      });
      final snackBar = SnackBar(
        content: Text(
            'Location and product details sent to Firebase: $selectedLocation'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      final snackBar = SnackBar(
        content: Text('Failed to send location and product details: $e'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
