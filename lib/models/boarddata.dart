import 'package:cloud_firestore/cloud_firestore.dart';

class BoardData {
  static Stream<QuerySnapshot> getPostsStreamForDepartment(String department) {
    return FirebaseFirestore.instance
        .collection('departments')
        .doc(department)
        .collection('posts')
        .snapshots();
  }
}
