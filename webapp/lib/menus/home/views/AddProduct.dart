import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:webapp/TextField.dart';
import 'package:webapp/product/product_repository.dart';
import 'package:webapp/upload_bloc/upload_bloc.dart';
import 'package:webapp/widgets/ingredientsAdd.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ingredient1Controller = TextEditingController();
  final ingredient2Controller = TextEditingController();
  final ingredient3Controller = TextEditingController();
  final ingredient4Controller = TextEditingController();
  String? _errorMsg;
  late Product product;

  @override
  void initState() {
    product = Product.empty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UploadPictureBloc, UploadPictureState>(
        listener: (context, state) {
          if (state is UploadPictureLoading) {
          } else if (state is UploadPictureSuccess) {
            setState(() {
              product.image = state.url;
            });
          }
        },
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Add Product',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxHeight: 1000,
                        maxWidth: 1000,
                      );
                      if (image != null && context.mounted) {
                        context.read<UploadPictureBloc>().add(UploadPicture(
                            await image.readAsBytes(), basename(image.path)));
                      }
                    },
                    child: product.image.startsWith(('http'))
                        ? Container(
                            width: 400,
                            height: 400,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                    image: NetworkImage(product.image),
                                    fit: BoxFit.cover)))
                        : Ink(
                            width: 400,
                            height: 400,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.photo,
                                  size: 100,
                                  color: Colors.grey.shade200,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "Add a Picture here...",
                                  style: TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
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
                                hintText: 'Name',
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
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: IngredientTextField(
                                controller: ingredient2Controller,
                                hintText: 'Ingredient 2',
                                errorMsg: _errorMsg,
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
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: IngredientTextField(
                                controller: ingredient4Controller,
                                hintText: 'Ingredient 4',
                                errorMsg: _errorMsg,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              context.go('/add-product');
                              print('Add product tapped');
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
                              'Add Product',
                              style: TextStyle(
                                fontSize:
                                    20.0, // Increase font size for the button
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
        ));
  }
}
