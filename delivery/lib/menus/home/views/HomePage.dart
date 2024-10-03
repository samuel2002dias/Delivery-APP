// ignore_for_file: prefer_const_constructors, avoid_print, file_names

import 'package:delivery/menus/autenticacao/bloc/LogInBloc.dart';
import 'package:delivery/menus/home/views/BuyNowPage.dart';
import 'package:delivery/menus/home/views/DetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Ensure you have this import for Bloc usage
import 'package:flutter/cupertino.dart'; // Import for CupertinoIcons
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firebase Firestore

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0), // Adjust the height as needed
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Add padding to all sides
          child: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // First column: IconButton
                IconButton(
                  onPressed: () {},
                  icon: const Icon(CupertinoIcons.cart),
                ),
                Spacer(), // Pushes the image to the center
                Center(
                  child: Image.asset(
                    'images/Logo.png',
                    height: 70,
                  ),
                ),
                Spacer(), // Pushes the button to the right
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
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products available'));
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
                    duration: Duration(
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
                          offset: Offset(2, 2), // Offset in x and y direction
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
                                      style: TextStyle(
                                        fontSize:
                                            20.0, // Larger font size for the name
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
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
                                style: TextStyle(
                                  fontSize: 18.0, // Font size for the price
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(
                                      252, 185, 19, 1), // Color for the price
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          BuyNowPage(productId: product.id),
                                    ),
                                  );
                                  print('Add button pressed');
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
}
