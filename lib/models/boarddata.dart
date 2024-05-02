import 'package:cloud_firestore/cloud_firestore.dart';

class BoardData {
  static Stream<QuerySnapshot> getPostsStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
