import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final priceController = TextEditingController(); // New controller for price
  final ingredient1Controller = TextEditingController();
  final ingredient2Controller = TextEditingController();
  final ingredient3Controller = TextEditingController();
  final ingredient4Controller = TextEditingController();
  String? _errorMsg;
  late Product product;
  List<String> imageNames = [];
  String? selectedImageName;

  @override
  void initState() {
    super.initState();
    print('initState called');
    product = Product.empty;
    _fetchProductDetails();
    _fetchImagesFromStorage();
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
          priceController.text =
              data['price']?.toString() ?? ''; // Populate price
          Map<String, dynamic> ingredients = data['ingredients'] ?? {};
          ingredient1Controller.text = ingredients['ingredient1'] ?? '';
          ingredient2Controller.text = ingredients['ingredient2'] ?? '';
          ingredient3Controller.text = ingredients['ingredient3'] ?? '';
          ingredient4Controller.text = ingredients['ingredient4'] ?? '';
          product = Product(
            productID: widget.productID,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            image: data['image'] ?? '',
            price: data['price'] ?? 0.0,
            ingredients: Ingredients(
              ingredientID: data['ingredientID'] ?? '',
              ingredientName1: ingredients['ingredient1'] ?? '',
              ingredientName2: ingredients['ingredient2'] ?? '',
              ingredientName3: ingredients['ingredient3'] ?? '',
              ingredientName4: ingredients['ingredient4'] ?? '',
            ),
          );
          selectedImageName = data['image'] ?? '';
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

  Future<void> _fetchImagesFromStorage() async {
    try {
      print('Fetching images from Firebase Storage');
      final ListResult result = await FirebaseStorage.instance
          .refFromURL('gs://delivery-68030.appspot.com')
          .listAll();
      print('Found ${result.items.length} items in storage');

      List<String> names = [];
      for (var ref in result.items) {
        print('Fetching metadata for item: ${ref.fullPath}');
        final FullMetadata metadata = await ref.getMetadata();
        if (metadata.contentType == 'image/jpeg' ||
            metadata.contentType == 'image/png') {
          print('Fetched image name: ${ref.name}');
          names.add(ref.name);
        }
      }

      setState(() {
        imageNames = names;
      });
      print('Fetched ${names.length} images from Firebase Storage');
    } catch (e) {
      print('Error fetching images from storage: $e');
      if (e is FirebaseException) {
        print('FirebaseException code: ${e.code}');
        print('FirebaseException message: ${e.message}');
      }
    }
  }

  Future<String> _getImageUrl(String imageName) async {
    return await FirebaseStorage.instance
        .refFromURL('gs://delivery-68030.appspot.com/$imageName')
        .getDownloadURL();
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl;
        if (selectedImageName != null) {
          imageUrl = await _getImageUrl(selectedImageName!);
        }

        await FirebaseFirestore.instance
            .collection('product')
            .doc(widget.productID)
            .update({
          'name': nameController.text,
          'description': descriptionController.text,
          'price': double.tryParse(priceController.text) ?? 0.0, // Update price
          'ingredients': {
            'ingredient1': ingredient1Controller.text,
            'ingredient2': ingredient2Controller.text,
            'ingredient3': ingredient3Controller.text,
            'ingredient4': ingredient4Controller.text,
          },
          'image': imageUrl,
        });
      } catch (e) {
        print('Error updating product: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                          child: MyTextField(
                            controller: priceController,
                            hintText: 'Price',
                            obscureText: false,
                            keyboardType: TextInputType.number,
                            errorMsg: _errorMsg,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please fill in this field';
                              }
                              if (double.tryParse(val) == null) {
                                return 'Please enter a valid number';
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
                    const Text(
                      'Images Available',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    imageNames.isEmpty
                        ? const Text('No images found.')
                        : GridView.builder(
                            shrinkWrap: true,
                            itemCount: imageNames.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing:
                                  5, // Reduce spacing between columns
                              mainAxisSpacing: 5, // Reduce spacing between rows
                              childAspectRatio: 3, // Make the grid tiles square
                            ),
                            itemBuilder: (context, index) {
                              return FutureBuilder<String>(
                                future: _getImageUrl(imageNames[index]),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return const Center(
                                        child: Icon(Icons.error));
                                  } else {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedImageName = imageNames[index];
                                        });
                                      },
                                      child: GridTile(
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                    2.0), // Reduce padding around the image
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 1.0), // Add border
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0), // Add border radius
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0), // Clip image to border radius
                                                  child: Image.network(
                                                    snapshot.data!,
                                                    fit: BoxFit.cover,
                                                    width:
                                                        400, // Reduce image width
                                                    height:
                                                        200, // Reduce image height
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (selectedImageName ==
                                                imageNames[index])
                                              const Icon(Icons.check_circle,
                                                  color: Colors.green),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
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
