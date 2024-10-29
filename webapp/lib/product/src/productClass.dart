import 'dart:typed_data';

import 'package:webapp/product/src/models/models.dart';

abstract class ProductClass {
  Future<List<Product>> getProduct();
  Future<String> sendImage(Uint8List file, String name);
  Future<void> createProduct(Product product);
}
