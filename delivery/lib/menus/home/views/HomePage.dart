// ignore_for_file: avoid_types_as_parameter_names, use_build_context_synchronously, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/menus/autenticacao/bloc/LogInBloc.dart';
import 'package:delivery/menus/home/views/CartPage.dart';
import 'package:delivery/menus/home/views/DetailsPage.dart';
import 'package:delivery/menus/home/views/RequestList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> addToCart(
      String productId, Map<String, dynamic> productData, int quantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartRef =
          FirebaseFirestore.instance.collection('cart').doc(user.uid);
      final cartSnapshot = await cartRef.get();

      if (cartSnapshot.exists) {
        // If the cart already exists, update it
        final cartData = cartSnapshot.data() as Map<String, dynamic>;
        final products = List<Map<String, dynamic>>.from(cartData['products']);
        final productIndex =
            products.indexWhere((product) => product['id'] == productId);

        if (productIndex >= 0) {
          // If the product already exists in the cart, increment its quantity
          products[productIndex]['quantity'] += quantity;
        } else {
          // If the product does not exist in the cart, add it with the specified quantity
          products.add({
            'id': productId,
            'data': productData,
            'quantity': quantity,
          });
        }

        await cartRef.update({'products': products});
      } else {
        // If the cart does not exist, create it with the product
        await cartRef.set({
          'products': [
            {
              'id': productId,
              'data': productData,
              'quantity': quantity,
            }
          ]
        });
      }
    } else {
      print('User not signed in');
    }
  }

  void showAddToCartDialog(BuildContext context, String productId,
      Map<String, dynamic> productData) {
    int quantity = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add to Cart'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter quantity:'),
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
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await addToCart(productId, productData, quantity);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add to Cart'),
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
                                  builder: (BuildContext context) =>
                                      const CartPage(
                                    userId: '',
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
                const Spacer(), // Pushes the image to the center
                Center(
                  child: Image.asset(
                    'images/Logo.png',
                    height: 70,
                  ),
                ),
                const Spacer(), // Pushes the button to the right
                IconButton(
                  onPressed: () {
                    context.read<SignInBloc>().add(SignOutRequired());
                  },
                  icon: const Icon(CupertinoIcons.arrow_right_to_line),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('product').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              final product = products[index];
              final productData = product.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.all(8.0), // Set padding as needed
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
                    curve: Curves.easeInOut, // Set the curve of the animation
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(25.0), // Set border radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400
                              .withOpacity(0.5), // Shadow color with opacity
                          spreadRadius: 3, // Spread radius
                          blurRadius: 5, // Blur radius
                          offset:
                              const Offset(2, 2), // Offset in x and y direction
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
                                  productData['image'] ?? 'images/cheese.png',
                                  height: 130.0, // Adjust the height as needed
                                  width: 130.0, // Adjust the width as needed
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      productData['name'] ?? 'Product Name',
                                      style: const TextStyle(
                                        fontSize:
                                            20.0, // Larger font size for the name
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                  fontSize: 18.0, // Font size for the price
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(
                                      252, 185, 19, 1), // Color for the price
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
    );
  }

  Widget _buildRequestsPage(BuildContext context) {
    return const RequestList();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      _buildHomePage(context),
      _buildRequestsPage(context),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Requests',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromRGBO(252, 185, 19, 1),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
