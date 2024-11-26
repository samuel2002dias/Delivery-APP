// ignore_for_file: avoid_types_as_parameter_names, use_build_context_synchronously, file_names, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/menus/autenticacao/bloc/LogInBloc.dart';
import 'package:delivery/menus/home/views/CartPage.dart';
import 'package:delivery/menus/home/views/DetailsPage.dart';
import 'package:delivery/menus/home/views/RequestList.dart';
import 'package:delivery/translation_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery/product/src/firebase_product.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      context.read<SignInBloc>().add(SignOutRequired());
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void showAddToCartDialog(BuildContext context, String productId,
      Map<String, dynamic> productData) {
    int quantity = 1;
    final FirebaseProduct firebaseProduct = FirebaseProduct();
    final translationProvider =
        Provider.of<TranslationProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(translationProvider.translate('add_to_cart')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(translationProvider.translate('enter_quantity')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(translationProvider.translate('cancel')),
                ),
                TextButton(
                  onPressed: () async {
                    await firebaseProduct.addToCart(productId, productData);
                    Navigator.of(context).pop();
                    if (Navigator.canPop(context)) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const HomePage(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                  child: Text(translationProvider.translate('add_to_cart')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final translationProvider = Provider.of<TranslationProvider>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(100.0), // Adjust the height as needed
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Add padding to all sides
          child: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // First column: IconButton with cart count
                if (user != null)
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('cart')
                        .doc(user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      int itemCount = 0;
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final cartData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final products = cartData['products'] as List<dynamic>;
                        itemCount = products.fold(
                            0,
                            (sum, product) =>
                                sum + (product['quantity'] as int));
                      }
                      return Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => CartPage(
                                    userId: user.uid,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(CupertinoIcons.cart),
                          ),
                          if (itemCount > 0)
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '$itemCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                const Spacer(),
                // Pushes the image to the center
                Center(
                  child: Image.asset(
                    'images/Logo.png',
                    height: 70,
                  ),
                ),
                const Spacer(),
                // Pushes the button to the right
                GestureDetector(
                  onTap: () async {
                    final translationProvider =
                        Provider.of<TranslationProvider>(context,
                            listen: false);
                    if (translationProvider.locale.languageCode == 'en') {
                      await translationProvider.load(const Locale('pt'));
                    } else {
                      await translationProvider.load(const Locale('en'));
                    }
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Image.asset(
                      translationProvider.locale.languageCode == 'en'
                          ? 'images/uk.png'
                          : 'images/portugal.png',
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('product').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text(translationProvider
                          .translate('something_went_wrong')));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(translationProvider
                          .translate('no_products_available')));
                }

                final products = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = products[index];
                    final productData = product.data() as Map<String, dynamic>;

                    return Padding(
                      padding:
                          const EdgeInsets.all(8.0), // Set padding as needed
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  DetailsPage(productId: product.id),
                            ),
                          );
                          print('Container tapped');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(
                              seconds: 1), // Set the duration of the animation
                          curve: Curves
                              .easeInOut, // Set the curve of the animation
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                25.0), // Set border radius
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade400.withOpacity(
                                    0.5), // Shadow color with opacity
                                spreadRadius: 3, // Spread radius
                                blurRadius: 5, // Blur radius
                                offset: const Offset(
                                    2, 2), // Offset in x and y direction
                              ),
                            ],
                          ),
                          height: 150.0, // Specify the height of the container
                          width: double
                              .infinity, // Make the container take the full width
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(
                                        8.0), // Padding around the image
                                    child: ClipOval(
                                      child: Image.network(
                                        productData['image'] ??
                                            'images/cheese.png',
                                        height:
                                            100.0, // Adjust the height as needed
                                        width:
                                            100.0, // Adjust the width as needed
                                        fit: BoxFit
                                            .cover, // Ensure the image covers the entire area
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                          8.0), // Padding around the text
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            productData['name'] ??
                                                'Product Name',
                                            style: const TextStyle(
                                              fontSize:
                                                  20.0, // Larger font size for the name
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const SizedBox(
                                              height:
                                                  4.0), // Space between name and ingredients
                                          Text(
                                            productData['description'] ??
                                                'Description',
                                            style: TextStyle(
                                              fontSize:
                                                  16.0, // Smaller font size for the ingredients
                                              color: Colors.grey[700],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 8.0,
                                right: 8.0,
                                child: Row(
                                  children: [
                                    Text(
                                      '\$${productData['price'] ?? '0.00'}',
                                      style: const TextStyle(
                                        fontSize:
                                            18.0, // Font size for the price
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(252, 185, 19,
                                            1), // Color for the price
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showAddToCartDialog(
                                            context, product.id, productData);
                                      },
                                      icon: const Icon(
                                          CupertinoIcons.add_circled_solid),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsPage(BuildContext context) {
    final translationProvider = Provider.of<TranslationProvider>(context);
    return const RequestList();
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = Provider.of<TranslationProvider>(context);
    List<Widget> pages = [
      _buildHomePage(context),
      _buildRequestsPage(context),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: translationProvider.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: translationProvider.translate('requests'),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(252, 185, 19, 1),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
