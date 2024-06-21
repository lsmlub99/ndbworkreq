import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../setting/userprofileinfo.dart';

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
    File? profileImage,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      String? profileImageUrl;
      if (profileImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('$email.jpg');
        await ref.putFile(profileImage);
        profileImageUrl = await ref.getDownloadURL();
      }

      _userProfile = UserProfile(
        userId: email,
        nickname: nickname,
        department: department,
        profileImageUrl: profileImageUrl,
      );

      await _firestore.collection('users').doc(email).set({
        'nickname': _userProfile!.nickname,
        'department': _userProfile!.department,
        'userId': _userProfile!.userId,
        'profileImageUrl': _userProfile!.profileImageUrl,
      });

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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
          profileImageUrl: doc['profileImageUrl'], // Fixed here
        );
      } else {
        _userProfile = null;
      }
      notifyListeners();
    }
  }
}
