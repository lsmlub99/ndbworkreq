import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  UserProfile? _userProfile;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String nickname,
    required String? department,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _user = userCredential.user;

      _userProfile = UserProfile(
        userId: userCredential.user!.email!,
        nickname: nickname,
        department: department,
      );

      await _firestore.collection('users').doc(_userProfile!.userId).set({
        'nickname': _userProfile!.nickname,
        'department': _userProfile!.department,
        'userId': _userProfile!.userId
      });

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _user = userCredential.user;
      await _loadUserProfile();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
  }

  Future<void> _loadUserProfile() async {
    if (_user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(_user!.email).get();
      if (doc.exists) {
        _userProfile = UserProfile(
          userId: doc.id,
          nickname: doc['nickname'],
          department: doc['department'],
        );
      } else {
        _userProfile = null;
      }
      notifyListeners();
    }
  }
}
