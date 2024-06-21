import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  String? _userName;
  String? _profileImageUrl;
  String? _email;
  String? _department;
  bool _notificationsEnabled = false;

  String? get userName => _userName;
  String? get email => _email;
  String? get profileImageUrl => _profileImageUrl;
  String? get department => _department;
  bool get notificationsEnabled => _notificationsEnabled;

  User? get user => FirebaseAuth.instance.currentUser;

  UserProvider() {
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>?; // null 체크 추가
          _userName = data?['nickname'];
          _profileImageUrl = data?['profileImageUrl'];
          _email = user.email;
          _department = data?['department'];
          _notificationsEnabled =
              data?.containsKey('notificationsEnabled') == true
                  ? data!['notificationsEnabled']
                  : false;
          print(
              'Fetched data: username: $_userName, email: $_email, department: $_department, notificationsEnabled: $_notificationsEnabled');
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> updateUserName(String newName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .update({
        'nickname': newName,
      });
      _userName = newName;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(String newImageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .update({
        'profileImageUrl': newImageUrl,
      });
      _profileImageUrl = newImageUrl;
      notifyListeners();
    }
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .update({
        'notificationsEnabled': enabled,
      });
      _notificationsEnabled = enabled;
      notifyListeners();
    }
  }

  void clearUserData() {
    _userName = null;
    _profileImageUrl = null;
    _email = null;
    _department = null;
    _notificationsEnabled = false;
    notifyListeners();
  }
}
