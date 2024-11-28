import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;
import 'package:go_router/go_router.dart';
import 'package:webapp/translation_provider.dart';
import 'package:provider/provider.dart';

class BasePage extends StatefulWidget {
  final Widget child;
  const BasePage(this.child, {super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = userDoc['name'];
      });
    }
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    html.window.location.assign('/login');
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            TextButton(
              onPressed: () async {
                if (translationProvider.locale.languageCode == 'en') {
                  await translationProvider.load(const Locale('pt'));
                } else {
                  await translationProvider.load(const Locale('en'));
                }
                setState(() {});
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
              child: Image.asset(
                translationProvider.locale.languageCode == 'en'
                    ? 'images/uk.png'
                    : 'images/portugal.png',
                height: 30,
                width: 30,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(
                  top: 5.0), // Add top padding of 5 pixels
              child: GestureDetector(
                onTap: () {
                  context.go('/home'); // Navigate to /home
                },
                child: Image.asset(
                  'images/logo.png',
                  height: 80, // Adjust the height as needed
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => _logout(context),
              icon: const Icon(CupertinoIcons.arrow_right_to_line),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
