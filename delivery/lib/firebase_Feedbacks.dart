import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getFeedbacks(String productId) async {
  final feedbacksSnapshot = await FirebaseFirestore.instance
      .collection('feedbacks')
      .where('productId', isEqualTo: productId)
      .get();

  final feedbacks = feedbacksSnapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();

  for (var feedback in feedbacks) {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(feedback['userId'])
        .get();
    if (userDoc.exists) {
      feedback['name'] = userDoc.data()?['name'] ?? 'Unknown User';
    } else {
      feedback['name'] = 'Unknown User';
    }
  }

  return feedbacks;
}
