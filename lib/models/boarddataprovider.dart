import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BoardDataProvider extends ChangeNotifier {
  final Map<String, int> _currentPageMap = {};
  Stream<QuerySnapshot>? _postsStream;
  String? department; // department 필드를 추가합니다.

  Stream<QuerySnapshot>? get postsStream => _postsStream;

  void getPostsStreamForDepartment(String department) {
    this.department = department; // department 필드를 설정합니다.
    _postsStream = FirebaseFirestore.instance
        .collection('departments')
        .doc(department)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
    notifyListeners();
  }

  int getCurrentPage(String postId) {
    return _currentPageMap[postId] ?? 0;
  }

  void setCurrentPage(String postId, int pageIndex) {
    _currentPageMap[postId] = pageIndex;
    notifyListeners();
  }

  Future<void> deletePost(String postId, String department) async {
    try {
      await FirebaseFirestore.instance
          .collection('departments')
          .doc(department)
          .collection('posts')
          .doc(postId)
          .delete();
      notifyListeners();
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  Future<void> updatePostStatus(String postId, String newStatus) async {
    if (department != null) {
      try {
        await FirebaseFirestore.instance
            .collection('departments')
            .doc(department)
            .collection('posts')
            .doc(postId)
            .update({'status': newStatus});
        notifyListeners();
      } catch (e) {
        print('Error updating post status: $e');
      }
    } else {
      print('Department is null');
    }
  }
}
