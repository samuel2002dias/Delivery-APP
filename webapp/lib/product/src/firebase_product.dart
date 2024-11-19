import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:webapp/product/src/enitities/productEntity.dart';
import 'package:webapp/product/src/models/models.dart';
import 'package:webapp/product/src/productClass.dart';

class FirebaseProduct implements ProductClass {
  final productList = FirebaseFirestore.instance.collection('product');
  Future<List<Product>> getProduct() async {
    try {
      return await productList.get().then((value) => value.docs
          .map((e) => Product.fromEntity(ProductEntity.fromJson(e.data())))
          .toList());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<String> sendImage(Uint8List file, String name) async {
    try {
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(name);

      await firebaseStorageRef.putData(
          file,
          SettableMetadata(
            contentType: 'image/jpeg',
          ));
      return await firebaseStorageRef.getDownloadURL();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> createProduct(Product product) async {
    try {
      return await productList
          .doc(product.productID)
          .set(product.toEntity().toJson());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> updateProduct(String productID, String name, String description,
      double price, Map<String, String> ingredients, String? imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('product')
          .doc(productID)
          .update({
        'name': name,
        'description': description,
        'price': price,
        'ingredients': ingredients,
        'image': imageUrl,
      });
    } catch (e) {
      log('Error updating product: $e');
      rethrow;
    }
  }

  Future<String> getImageUrl(String imageName) async {
    return await FirebaseStorage.instance
        .refFromURL('gs://delivery-68030.appspot.com/$imageName')
        .getDownloadURL();
  }

  Future<List<String>> fetchImagesFromStorage() async {
    try {
      final ListResult result = await FirebaseStorage.instance
          .refFromURL('gs://delivery-68030.appspot.com')
          .listAll();

      List<String> names = [];
      for (var ref in result.items) {
        final FullMetadata metadata = await ref.getMetadata();
        if (metadata.contentType == 'image/jpeg' ||
            metadata.contentType == 'image/png') {
          names.add(ref.name);
        }
      }
      return names;
    } catch (e) {
      log('Error fetching images from storage: $e');
      rethrow;
    }
  }


}
