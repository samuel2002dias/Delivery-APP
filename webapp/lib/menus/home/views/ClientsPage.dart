import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webapp/translation_provider.dart';

class ClientsPage extends StatefulWidget {
  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> _getFeedbackCount(String userId) async {
    final feedbacks = await _firestore
        .collection('feedbacks')
        .where('userId', isEqualTo: userId)
        .get();
    return feedbacks.docs.length;
  }

  Future<void> _banClient(String userId) async {
    try {
      // Delete user from Firestore
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error banning client: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translationProvider.translate('list_of_clients')),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(translationProvider.translate('no_clients_found')));
          }

          final clients = snapshot.data!.docs;

          return ListView.builder(
            itemCount: (clients.length / 2).ceil(),
            itemBuilder: (context, index) {
              final client1 = clients[index * 2];
              final client2 = (index * 2 + 1 < clients.length)
                  ? clients[index * 2 + 1]
                  : null;

              return Row(
                children: [
                  Expanded(
                    child: _buildClientCard(client1, translationProvider),
                  ),
                  if (client2 != null)
                    Expanded(
                      child: _buildClientCard(client2, translationProvider),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildClientCard(
      DocumentSnapshot client, TranslationProvider translationProvider) {
    return FutureBuilder<int>(
      future: _getFeedbackCount(client.id),
      builder: (context, feedbackSnapshot) {
        if (feedbackSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final feedbackCount = feedbackSnapshot.data ?? 0;
        final role = client['role'];
        final phone = client['phone'];

        Color iconColor;

        if (role == 'Admin') {
          iconColor = Color.fromRGBO(252, 185, 19, 1);
        } else if (role == 'Delivery Guy') {
          iconColor = Colors.blue;
        } else {
          iconColor = Colors.black;
        }

        return InkWell(
          onTap: () {
            context.go('/user-status/${client.id}');
          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Icon(Icons.person, size: 60.0, color: iconColor),
                    if (role != null && role == 'admin')
                      Icon(Icons.admin_panel_settings,
                          size: 48.0, color: iconColor),
                  ],
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16.0),
                      Text(
                        client['name'] ??
                            translationProvider.translate('no_name'),
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      Row(
                        children: [
                          Text(
                            '${translationProvider.translate('email')}: ',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            client['email'] ??
                                translationProvider.translate('no_email'),
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '${translationProvider.translate('role')}: ',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            client['role'] ??
                                translationProvider.translate('no_role'),
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Text(
                            '${translationProvider.translate('phone')}: ',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            phone != null && phone.isNotEmpty ? phone : '-',
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '${translationProvider.translate('feedbacks_given')}: ',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$feedbackCount',
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Same border radius as container
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ), // Reduced padding
                            ),
                            onPressed: () async {
                              await _banClient(client.id);
                            },
                            child: Text(
                              translationProvider.translate('ban_client'),
                              style: const TextStyle(
                                fontSize:
                                    16.0, // Reduced font size for the button
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Text color
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
