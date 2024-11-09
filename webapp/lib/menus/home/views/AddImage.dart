import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:webapp/menus/upload_bloc/upload_bloc.dart';
import 'package:webapp/product/src/models/ingredients.dart';
import 'package:webapp/product/src/models/product.dart';

class AddImage extends StatefulWidget {
  @override
  _AddAddImageState createState() => _AddAddImageState();
}

class _AddAddImageState extends State<AddImage> {
  late Product product;
  bool isUploadSuccess = false;

  @override
  void initState() {
    super.initState();
    product = Product(
      productID: '',
      image: '',
      name: '',
      description: '',
      price: 0.0,
      ingredients: Ingredients(
        ingredientID: '',
        ingredientName1: '',
        ingredientName2: '',
        ingredientName3: '',
        ingredientName4: '',
      ), // Replace with an appropriate Ingredients instance
    ); // Initialize the product here
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;

    return BlocListener<UploadPictureBloc, UploadPictureState>(
      listener: (context, state) {
        if (state is UploadPictureLoading) {
          // Handle loading state if needed
        } else if (state is UploadPictureSuccess) {
          setState(() {
            product.image = state.url;
            isUploadSuccess = true;
          });

          // Redirect to home page after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (context.mounted) {
              context.go('/');
            }
          });
        }
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Add the Image that you want to upload',
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
                    child: product.image.startsWith('http')
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
                  const SizedBox(
                    height: 20,
                  ),
                  if (isUploadSuccess) ...[
                    const Text(
                      "Upload Complete, you will be redirected to the home page",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
