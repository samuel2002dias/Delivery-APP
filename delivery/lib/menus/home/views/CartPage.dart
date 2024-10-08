import 'package:delivery/menus/home/views/BuyNowPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<Map<String, dynamic>>> _cartProductsFuture;

  @override
  void initState() {
    super.initState();
    _cartProductsFuture = _fetchCartProducts();
  }

  Future<List<Map<String, dynamic>>> _fetchCartProducts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      final userId = user.uid;
      print('Fetching products for user: $userId');
      final querySnapshot =
          await FirebaseFirestore.instance.collection('cart').doc(userId).get();

      if (!querySnapshot.exists) {
        print('No products found in the cart collection for user $userId.');
        return [];
      } else {
        print('Products fetched successfully for user $userId.');
      }

      final cartData = querySnapshot.data() as Map<String, dynamic>;
      final products = List<Map<String, dynamic>>.from(cartData['products']);

      return products;
    } catch (e) {
      print('Error fetching cart products: $e');
      rethrow;
    }
  }

  Future<void> _removeProductFromCart(String productId, int quantity) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      final userId = user.uid;
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(userId);

      final cartSnapshot = await cartRef.get();
      if (!cartSnapshot.exists) {
        throw Exception('Cart does not exist for user $userId.');
      }

      final cartData = cartSnapshot.data() as Map<String, dynamic>;
      final products = List<Map<String, dynamic>>.from(cartData['products']);

      final productIndex =
          products.indexWhere((product) => product['id'] == productId);
      if (productIndex == -1) {
        throw Exception('Product not found in cart.');
      }

      if (quantity > 1) {
        products[productIndex]['quantity'] = quantity - 1;
      } else {
        products.removeAt(productIndex);
      }

      await cartRef.update({'products': products});
      print('Product removed successfully.');

      // Update the state to reflect the changes
      setState(() {
        _cartProductsFuture = _fetchCartProducts();
      });
    } catch (e) {
      print('Error removing product from cart: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Center(
              child: Image.asset(
                'images/Logo.png',
                height: 70,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cart',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _cartProductsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products in cart.'));
                }

                final products = snapshot.data!;
                return SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final productData = products[index];
                      final productDetails =
                          productData['data'] as Map<String, dynamic>;
                      final productId = productData['id'];
                      final quantity = productData['quantity'] ?? 1;
                      print('Rendering product: $productData');
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          leading: ClipOval(
                            child: Image.network(
                              productDetails['image'] ?? 'images/cheese.png',
                              height: 50.0,
                              width: 50.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            productDetails['name'] ?? 'Product Name',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productDetails['description'] ?? 'Description',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Quantity: $quantity',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () async {
                                  await _removeProductFromCart(
                                      productId, quantity);
                                },
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '\$${productDetails['price'] ?? '0.00'}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(252, 185, 19, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _cartProductsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No products in cart.'));
              }

              final products = snapshot.data!;
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => BuyNowPage(
                          products: products,
                          productId: '',
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    elevation: 3.0,
                    backgroundColor: const Color.fromRGBO(252, 185, 19, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Buy Now",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
