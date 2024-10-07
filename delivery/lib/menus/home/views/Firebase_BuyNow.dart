import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery/menus/home/views/MapView.dart';

Future<void> sendLocationToFirebase({
  required BuildContext context,
  required String productId,
  required Map<String, dynamic>? productData,
  required TextEditingController numberController,
  required TextEditingController observationsController,
  required TextEditingController addressController,
  required LatLng selectedLocation,
  required Function(String) showDialog,
  required String paymentMethod, // Add this parameter
}) async {
  if (productData == null) {
    showDialog('Product data is not loaded yet.');
    return;
  }

  try {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    String? email = user?.email; // Get the user's email

    Map<String, dynamic> requestData = {
      'productId': productId,
      'productName': productData['name'],
      'productPrice': productData['price'],
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'In Progress',
      'nif': numberController.text.isNotEmpty ? numberController.text : null,
      'observations': observationsController.text.isNotEmpty
          ? observationsController.text
          : null,
      'payment': paymentMethod, // Set the payment method
      'User email': email, // Add the user's email
    };

    if (addressController.text.isNotEmpty) {
      requestData['address'] = addressController.text;
    } else {
      requestData['latitude'] = selectedLocation.latitude;
      requestData['longitude'] = selectedLocation.longitude;
    }

    await FirebaseFirestore.instance.collection('requests').add(requestData);
    showDialog('Order requested');
  } catch (e) {
    showDialog('Failed to send location and product details: $e');
  }
}

Future<void> onPinPointLocation({
  required BuildContext context,
  required Function(LatLng) onLocationSelected,
  required TextEditingController addressController,
}) async {
  final result = await Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => MapView()),
  );

  if (result != null && result is LatLng) {
    onLocationSelected(result);
    addressController.text = '${result.latitude}, ${result.longitude}';
  }
}
