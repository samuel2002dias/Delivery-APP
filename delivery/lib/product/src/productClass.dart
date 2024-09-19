import 'package:delivery/product/src/models/models.dart';

abstract class ProductClass {
  Future<List<Product>> getProduct();
}
