// ignore_for_file: avoid_print, library_private_types_in_public_api, file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:webapp/TextField.dart';
import 'package:webapp/menus/create_bloc/create_bloc.dart';
import 'package:webapp/product/product_repository.dart';
import 'package:webapp/menus/upload_bloc/upload_bloc.dart';
import 'package:webapp/widgets/ingredientsAdd.dart';
import 'package:provider/provider.dart';
import 'package:webapp/translation_provider.dart';

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
  bool creationRequired = false;

  @override
  void initState() {
    product = Product.empty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = Provider.of<TranslationProvider>(context);

    return BlocListener<CreateProductBloc, CreateProductState>(
      listener: (context, state) {
        if (state is CreateProductSuccess) {
          setState(() {
            creationRequired = false;
            context.go('/');
          });
          context.go('/');
        } else if (state is CreateProductLoading) {
          setState(() {
            creationRequired = true;
          });
        }
      },
      child: BlocListener<UploadPictureBloc, UploadPictureState>(
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
                    Text(
                      translationProvider.translate('add_product'),
                      style: const TextStyle(
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
                                  Text(
                                    translationProvider
                                        .translate('add_picture'),
                                    style: const TextStyle(color: Colors.grey),
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
                                  hintText:
                                      translationProvider.translate('name'),
                                  obscureText: false,
                                  keyboardType: TextInputType.text,
                                  errorMsg: _errorMsg,
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return translationProvider
                                          .translate('fill_field');
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
                                  hintText: translationProvider
                                      .translate('description'),
                                  obscureText: false,
                                  keyboardType: TextInputType.text,
                                  errorMsg: _errorMsg,
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return translationProvider
                                          .translate('fill_field');
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
                                  hintText:
                                      translationProvider.translate('price'),
                                  obscureText: false,
                                  keyboardType: TextInputType.number,
                                  errorMsg: _errorMsg,
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return translationProvider
                                          .translate('fill_field');
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
                                  hintText: translationProvider
                                      .translate('ingredient1'),
                                  errorMsg: _errorMsg,
                                  validator: (val) {
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: IngredientTextField(
                                  controller: ingredient2Controller,
                                  hintText: translationProvider
                                      .translate('ingredient2'),
                                  errorMsg: _errorMsg,
                                  validator: (val) {
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
                                  hintText: translationProvider
                                      .translate('ingredient3'),
                                  errorMsg: _errorMsg,
                                  validator: (val) {
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: IngredientTextField(
                                  controller: ingredient4Controller,
                                  hintText: translationProvider
                                      .translate('ingredient4'),
                                  errorMsg: _errorMsg,
                                  validator: (val) {
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    product.name = nameController.text;
                                    product.description =
                                        descriptionController.text;
                                    product.price =
                                        double.parse(priceController.text);
                                    product.ingredients.ingredientID =
                                        const Uuid().v1();
                                    product.ingredients.ingredientName1 =
                                        ingredient1Controller.text;
                                    product.ingredients.ingredientName2 =
                                        ingredient2Controller.text;
                                    product.ingredients.ingredientName3 =
                                        ingredient3Controller.text;
                                    product.ingredients.ingredientName4 =
                                        ingredient4Controller.text;
                                  });
                                  print(product.toString());
                                  context
                                      .read<CreateProductBloc>()
                                      .add(CreateProduct(product));
                                }
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
                              child: Text(
                                translationProvider.translate('add_product'),
                                style: const TextStyle(
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
          )),
    );
  }
}
