import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:webapp/menus/home/views/ClientsPage.dart';
import 'package:webapp/menus/home/views/RequestPage.dart';
import 'ProductPage.dart'; // Import the ProductPage

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<String?> getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc['role'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            const TabBar(
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
              child: FutureBuilder<String?>(
                future: getUserRole(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    if (snapshot.data == 'Admin') {
                      return TabBarView(
                        children: [
                          const ProductPage(), // Admin has access to all tabs
                          const RequestPage(),
                          ClientsPage(),
                        ],
                      );
                    } else if (snapshot.data == 'Delivery Guy') {
                      return const TabBarView(
                        children: [
                          Center(child: Text('Access Denied')),
                          RequestPage(), // Delivery Guy has access only to Requests
                          Center(child: Text('Access Denied')),
                        ],
                      );
                    } else {
                      return const TabBarView(
                        children: [
                          Center(child: Text('Access Denied')),
                          Center(child: Text('Access Denied')),
                          Center(child: Text('Access Denied')),
                        ],
                      );
                    }
                  } else {
                    return const Center(child: Text('No role found'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
