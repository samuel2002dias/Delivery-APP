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
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:webapp/translation_provider.dart';

class AddImage extends StatefulWidget {
  @override
  _AddAddImageState createState() => _AddAddImageState();
}

class _AddAddImageState extends State<AddImage> {
  late Product product;
  bool isUploadSuccess = false;
  List<String> imageNames = [];

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
      ),
    );
    _fetchImagesFromStorage();
  }

  Future<void> _fetchImagesFromStorage() async {
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

      setState(() {
        imageNames = names;
      });
    } catch (e) {
      print('Error fetching images from storage: $e');
    }
  }

  Future<void> _removeImage(String imageName) async {
    try {
      await FirebaseStorage.instance
          .refFromURL('gs://delivery-68030.appspot.com/$imageName')
          .delete();
      setState(() {
        imageNames.remove(imageName);
      });
    } catch (e) {
      print('Error removing image: $e');
    }
  }

  Future<String> _getImageUrl(String imageName) async {
    return await FirebaseStorage.instance
        .refFromURL('gs://delivery-68030.appspot.com/$imageName')
        .getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;
    final translationProvider = Provider.of<TranslationProvider>(context);

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
              context.go('/home');
            }
          });
        }
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: SingleChildScrollView(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          translationProvider.translate('add_image'),
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
                              context.read<UploadPictureBloc>().add(
                                  UploadPicture(await image.readAsBytes(),
                                      basename(image.path)));
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
                                      Text(
                                        translationProvider
                                            .translate('add_picture'),
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      )
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (isUploadSuccess) ...[
                          Text(
                            translationProvider.translate('upload_complete'),
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translationProvider.translate('images_available'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 10),
                        imageNames.isEmpty
                            ? Text(translationProvider
                                .translate('no_images_found'))
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: imageNames.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      FutureBuilder<String>(
                                        future: _getImageUrl(imageNames[index]),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return const Center(
                                                child: Icon(Icons.error));
                                          } else {
                                            return Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .white, // Set background color to white
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(
                                                            0.1), // Shadow color
                                                    spreadRadius:
                                                        2, // Spread radius
                                                    blurRadius:
                                                        5, // Blur radius
                                                    offset: const Offset(0,
                                                        3), // Offset in x and y direction
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.network(
                                                      snapshot.data!,
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      imageNames[index],
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold), // Make text bold
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    onPressed: () {
                                                      _removeImage(
                                                          imageNames[index]);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      const Divider(), // Add a divider between rows
                                    ],
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
