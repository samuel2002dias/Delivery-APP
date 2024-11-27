// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:delivery/ProductCard.dart';
import 'package:delivery/menus/home/views/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:delivery/user/src/models/user.dart';
import 'package:delivery/user/firebase_user.dart'; // Import FirebaseUserRepo
import 'package:provider/provider.dart';
import 'package:delivery/translation_provider.dart';

class FeedbackPage extends StatefulWidget {
  final String productId;

  const FeedbackPage({Key? key, required this.productId}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _feedbackController = TextEditingController();
  final FirebaseUserRepo _firebaseUserRepo =
      FirebaseUserRepo(); // Initialize FirebaseUserRepo

  @override
  void initState() {
    super.initState();
    // Log the productId to check if it's being passed correctly
    print('Product ID: ${widget.productId}');
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userDetails = await _firebaseUserRepo.fetchUserDetails();
      setState(() {
        _emailController.text = userDetails['email'] ?? '';
        _nameController.text = userDetails['name'] ?? '';
      });
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  Future<Map<String, dynamic>?> _fetchProductDetails() async {
    if (widget.productId.isEmpty) {
      throw AssertionError('Product ID cannot be empty');
    }

    // Log the productId to check if it's being used correctly
    print('\nFetching details for Product ID: ${widget.productId}\n');

    final doc = await FirebaseFirestore.instance
        .collection('product')
        .doc(widget.productId)
        .get();

    if (doc.exists) {
      return doc.data();
    } else {
      return null;
    }
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('feedbacks').add({
          'userId': user.uid,
          'feedback': _feedbackController.text,
          'productId': widget.productId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  Provider.of<TranslationProvider>(context, listen: false)
                      .translate('feedback_submitted'))),
        );

        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = Provider.of<TranslationProvider>(context);

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder<Map<String, dynamic>?>(
              future: _fetchProductDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                      child: Text(
                          translationProvider.translate('product_not_found')));
                }

                final productDetails = snapshot.data!;

                return Column(
                  children: [
                    SimpleProductCard(productDetails: productDetails),
                    const SizedBox(height: 16.0), // Spacer added here
                    const Divider(), // Horizontal line added here
                  ],
                );
              },
            ),
            const SizedBox(height: 16.0),
            Text(
              translationProvider.translate('leave_feedback'),
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(252, 185, 19, 1),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              translationProvider.translate('feedback_important'),
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 14.0),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(252, 185, 19, 1),
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(252, 185, 19, 1),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(252, 185, 19, 1),
                        ),
                      ),
                      labelText: translationProvider.translate('name'),
                      labelStyle: const TextStyle(
                        color: Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translationProvider
                            .translate('please_enter_name');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(252, 185, 19, 1),
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(252, 185, 19, 1),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(252, 185, 19, 1),
                        ),
                      ),
                      labelText: translationProvider.translate('email'),
                      labelStyle: const TextStyle(
                        color: Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translationProvider
                            .translate('please_enter_email');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _feedbackController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(252, 185, 19, 1),
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(252, 185, 19, 1),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(252, 185, 19, 1),
                        ),
                      ),
                      labelText: translationProvider.translate('feedback'),
                      labelStyle: const TextStyle(
                        color: Color.fromRGBO(252, 185, 19, 1),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return translationProvider
                            .translate('please_enter_feedback');
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: TextButton(
                        onPressed: _submitFeedback,
                        style: TextButton.styleFrom(
                          elevation: 3.0,
                          backgroundColor:
                              const Color.fromRGBO(252, 185, 19, 1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          translationProvider.translate('submit'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
