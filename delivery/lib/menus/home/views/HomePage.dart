// ignore_for_file: prefer_const_constructors, avoid_print, file_names

import 'package:delivery/menus/autenticacao/bloc/LogInBloc.dart';
import 'package:delivery/menus/home/views/BuyNowPage.dart';
import 'package:delivery/menus/home/views/DetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Ensure you have this import for Bloc usage
import 'package:flutter/cupertino.dart'; // Import for CupertinoIcons

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
      body: ListView.builder(
        itemCount:
            1, // Adjust the item count as needed -  Replace with firebase data
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(8.0), // Set padding as needed
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext context) => DetailsPage()));
                print('Container tapped');
              },
              child: AnimatedContainer(
                duration:
                    Duration(seconds: 1), // Set the duration of the animation
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
                width:
                    double.infinity, // Make the container take the full width
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(
                              8.0), // Padding around the image
                          child: ClipOval(
                            child: Image.asset(
                              'images/cheese.png',
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
                                  'CheeseBurguer', //  Replace with firebase data
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
                                  'Description', //  Replace with firebase data
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
                            '\$9.99', // Replace with firebase data
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
                                          Buynow()));
                              print('Add button pressed');
                            },
                            icon: const Icon(CupertinoIcons.add_circled_solid),
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
      ), // Placeholder for the body content
    );
  }
}
