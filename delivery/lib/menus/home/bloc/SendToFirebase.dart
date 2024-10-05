import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseService {
  LatLng selectedLocation =
      const LatLng(38.71667, -9.13333); // Default to Lisbon, Portugal
  Map<String, dynamic>? productData;
  String deliveryStatus = 'In preparation'; // Default status

  Future<DocumentSnapshot> getProductDetails(String productId) async {
    return await FirebaseFirestore.instance
        .collection('product')
        .doc(productId)
        .get();
  }

  Future<void> sendLocationToFirebase({
    required String productId,
  }) async {
    if (productData == null) {
      throw Exception('Product data is not initialized.');
    }

    try {
      await FirebaseFirestore.instance.collection('requests').add({
        'productId': productId,
        'productName': productData!['name'],
        'productPrice': productData!['price'],
        'latitude': selectedLocation.latitude,
        'longitude': selectedLocation.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'status': deliveryStatus,
      });
    } catch (e) {
      throw Exception('Failed to send location and product details: $e');
    }
  }
}
