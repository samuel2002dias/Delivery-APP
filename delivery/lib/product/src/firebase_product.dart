import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/product/src/enitities/productEntity.dart';
import 'package:delivery/product/src/models/models.dart';
import 'package:delivery/product/src/productClass.dart';

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
}
