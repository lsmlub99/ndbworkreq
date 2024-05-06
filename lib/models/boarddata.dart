import 'package:cloud_firestore/cloud_firestore.dart';

class BoardData {
  static Stream<QuerySnapshot> getPostsStreamForDepartment(String department) {
    return FirebaseFirestore.instance
        .collection('departments')
        .doc(department)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<void> deletePost(String postId, String department) async {
    try {
      await FirebaseFirestore.instance
          .collection('departments')
          .doc(department)
          .collection('posts')
          .doc(postId)
          .delete();
    } catch (e) {
      print('Error deleting post: $e');
    }
  }
}
