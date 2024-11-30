import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:webapp/menus/home/views/ClientsPage.dart';
import 'package:webapp/menus/home/views/RequestPage.dart';
import 'package:webapp/menus/home/views/StatsPage.dart';
import 'ProductPage.dart'; // Import the ProductPage
import 'package:provider/provider.dart';
import 'package:webapp/translation_provider.dart'; // Import the TranslationProvider

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
    final translator = Provider.of<TranslationProvider>(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              indicatorColor: const Color.fromRGBO(252, 185, 19, 1),
              labelColor:
                  Colors.black, // Set the selected tab text color to black
              unselectedLabelColor:
                  Colors.grey, // Optionally set the unselected tab text color
              tabs: [
                Tab(text: translator.translate('products')),
                Tab(text: translator.translate('requests')),
                Tab(text: translator.translate('list_of_clients')),
                Tab(text: translator.translate('stats_page')),
              ],
            ),
            Expanded(
              child: FutureBuilder<String?>(
                future: getUserRole(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            '${translator.translate('error')}: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    if (snapshot.data == 'Admin') {
                      return TabBarView(
                        children: [
                          const ProductPage(),
                          const RequestPage(),
                          ClientsPage(),
                          const StatsPage(),
                        ],
                      );
                    } else if (snapshot.data == 'Delivery Guy') {
                      return TabBarView(
                        children: [
                          Center(
                              child:
                                  Text(translator.translate('access_denied'))),
                          const RequestPage(), // Delivery Guy has access only to Requests
                          Center(
                              child:
                                  Text(translator.translate('access_denied'))),
                          const StatsPage(),
                        ],
                      );
                    } else {
                      return TabBarView(
                        children: [
                          Center(
                              child:
                                  Text(translator.translate('access_denied'))),
                          Center(
                              child:
                                  Text(translator.translate('access_denied'))),
                          Center(
                              child:
                                  Text(translator.translate('access_denied'))),
                          Center(
                              child:
                                  Text(translator.translate('access_denied'))),
                        ],
                      );
                    }
                  } else {
                    return Center(
                        child: Text(translator.translate('no_role_found')));
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
