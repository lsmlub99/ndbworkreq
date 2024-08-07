import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BoardDataProvider extends ChangeNotifier {
  final Map<String, Map<String, int>> _currentPageMap =
      {}; // 부서별로 currentPageMap을 관리합니다.
  Stream<QuerySnapshot>? _postsStream;
  String? department; // department 필드를 추가합니다.

  Stream<QuerySnapshot>? get postsStream => _postsStream;

  String? _currentUserDepartment;

  Future<void> fetchCurrentUserDepartment(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          _currentUserDepartment = data['department'];
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error fetching user department: $e');
    }
  }

  String? get currentUserDepartment => _currentUserDepartment;

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

  int getCurrentPage(String department, String postId) {
    return _currentPageMap[department]?[postId] ?? 0;
  }

  void setCurrentPage(String department, String postId, int pageIndex) {
    if (!_currentPageMap.containsKey(department)) {
      _currentPageMap[department] = {};
    }
    _currentPageMap[department]![postId] = pageIndex;
    notifyListeners();
  }

  Future<void> deletePost(String postId) async {
    if (department != null) {
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
    } else {
      print('Department is null');
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
