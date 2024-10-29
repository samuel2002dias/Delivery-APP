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


}
