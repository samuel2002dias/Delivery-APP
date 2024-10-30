import 'package:flutter/material.dart';
import 'package:webapp/menus/home/views/RequestPage.dart';
import 'ProductPage.dart'; // Import the ProductPage

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              indicatorColor: Color.fromRGBO(252, 185, 19, 1),
              labelColor:
                  Colors.black, // Set the selected tab text color to black
              unselectedLabelColor:
                  Colors.grey, // Optionally set the unselected tab text color
              tabs: [
                Tab(text: 'Products'),
                Tab(text: 'Requests'),
                Tab(text: 'Clients'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ProductPage(), // Redirect to ProductPage
                  RequestPage(),
                  Center(child: Text('Clients Page')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
