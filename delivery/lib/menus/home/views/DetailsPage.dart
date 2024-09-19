// ignore_for_file: file_names

import 'package:delivery/IngredientsWidget.dart';
import 'package:delivery/menus/home/views/BuyNowPage.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

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
            // Pushes the button to the right
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(3, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(30), // Add border radius to the image
                child: Image.asset(
                  'images/cheese.png',
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 40,
                  fit: BoxFit.contain, // Ensure the image covers the container
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(3, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 14.0),
                              child: Text(
                                "CheeseBurger",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              child: Padding(
                            padding: EdgeInsets.only(
                                top: 14.0), // Apply padding only on top
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "\$9.99",
                                style: TextStyle(
                                  color: Color.fromRGBO(252, 185, 19, 1),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                )),
            const SizedBox(height: 30),
            const Row(
              children: [
                MyWidget(
                  name: "Tomato",
                  icon: FontAwesomeIcons.carrot,
                ),
                SizedBox(width: 12),
                MyWidget(
                  name: "Lettuce",
                  icon: FontAwesomeIcons.carrot,
                ),
                SizedBox(width: 14),
                MyWidget(name: "Meat", icon: FontAwesomeIcons.drumstickBite),
                SizedBox(width: 14),
                MyWidget(name: "Cheese", icon: FontAwesomeIcons.cheese),
                SizedBox(width: 14),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) => const Buynow()));
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
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  elevation: 3.0,
                  backgroundColor: const Color.fromRGBO(252, 185, 19, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
