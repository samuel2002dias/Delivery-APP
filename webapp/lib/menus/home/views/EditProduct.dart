import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:webapp/TextField.dart';
import 'package:webapp/product/src/models/ingredients.dart';
import 'package:webapp/product/src/models/product.dart';
import 'package:webapp/widgets/ingredientsAdd.dart';

class EditProductPage extends StatefulWidget {
  final String productID;

  const EditProductPage({Key? key, required this.productID}) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final ingredient1Controller = TextEditingController();
  final ingredient2Controller = TextEditingController();
  final ingredient3Controller = TextEditingController();
  final ingredient4Controller = TextEditingController();
  String? _errorMsg;
  late Product product;

  @override
  void initState() {
    super.initState();
    product = Product.empty;
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      print('Fetching product details for ID: ${widget.productID}');
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('product')
          .doc(widget.productID)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Product data: $data');
        setState(() {
          nameController.text = data['name'] ?? '';
          descriptionController.text = data['description'] ?? '';
          Map<String, dynamic> ingredients = data['ingredients'] ?? {};
          ingredient1Controller.text = ingredients['ingredientName1'] ?? '';
          ingredient2Controller.text = ingredients['ingredientName2'] ?? '';
          ingredient3Controller.text = ingredients['ingredientName3'] ?? '';
          ingredient4Controller.text = ingredients['ingredientName4'] ?? '';
          product = Product(
            productID: widget.productID,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            image: data['image'] ?? '',
            price: data['price'] ?? 0.0,
            ingredients: Ingredients(
              ingredientID: data['ingredientID'] ?? '',
              ingredientName1: ingredients['ingredientName1'] ?? '',
              ingredientName2: ingredients['ingredientName2'] ?? '',
              ingredientName3: ingredients['ingredientName3'] ?? '',
              ingredientName4: ingredients['ingredientName4'] ?? '',
            ),
          );
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('product')
            .doc(widget.productID)
            .update({
          'name': nameController.text,
          'description': descriptionController.text,
          'ingredients': {
            'ingredient1': ingredient1Controller.text,
            'ingredient2': ingredient2Controller.text,
            'ingredient3': ingredient3Controller.text,
            'ingredient4': ingredient4Controller.text,
          },
        });
      } catch (e) {
        print('Error updating product: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Edit Product',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MyTextField(
                            controller: nameController,
                            hintText: 'Product Name',
                            obscureText: false,
                            keyboardType: TextInputType.text,
                            errorMsg: _errorMsg,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please fill in this field';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: MyTextField(
                            controller: descriptionController,
                            hintText: 'Description',
                            obscureText: false,
                            keyboardType: TextInputType.text,
                            errorMsg: _errorMsg,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please fill in this field';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: IngredientTextField(
                            controller: ingredient1Controller,
                            hintText: 'Ingredient 1',
                            errorMsg: _errorMsg,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please fill in this field';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: IngredientTextField(
                            controller: ingredient2Controller,
                            hintText: 'Ingredient 2',
                            errorMsg: _errorMsg,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please fill in this field';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: IngredientTextField(
                            controller: ingredient3Controller,
                            hintText: 'Ingredient 3',
                            errorMsg: _errorMsg,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please fill in this field';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: IngredientTextField(
                            controller: ingredient4Controller,
                            hintText: 'Ingredient 4',
                            errorMsg: _errorMsg,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please fill in this field';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _updateProduct();
                          context.go('/');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(
                              252, 185, 19, 1), // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Same border radius as container
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 32.0), // Increase padding
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 20.0, // Increase font size for the button
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
