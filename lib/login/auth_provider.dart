import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class UserProfile {
  final String userId;
  final String nickname;
  final String? department;
  final String? profileImageUrl;
  final String? fcmToken;

  UserProfile({
    required this.userId,
    required this.nickname,
    this.department,
    this.profileImageUrl,
    this.fcmToken,
  });
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
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

      // Get the FCM token
      String? fcmToken = await _fcm.getToken();

      _userProfile = UserProfile(
        userId: email,
        nickname: nickname,
        department: department,
        profileImageUrl: profileImageUrl,
        fcmToken: fcmToken,
      );

      await _firestore.collection('users').doc(email).set({
        'nickname': _userProfile!.nickname,
        'department': _userProfile!.department,
        'userId': _userProfile!.userId,
        'profileImageUrl': _userProfile!.profileImageUrl,
        'fcmToken': _userProfile!.fcmToken,
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
      final data = doc.data() as Map<String, dynamic>?; // Add this line
      if (data != null) {
        _userProfile = UserProfile(
          userId: doc.id,
          nickname: data['nickname'],
          department: data['department'],
          profileImageUrl: data['profileImageUrl'],
          fcmToken: data.containsKey('fcmToken')
              ? data['fcmToken']
              : null, // Check if 'fcmToken' exists
        );
      } else {
        _userProfile = null;
      }
      notifyListeners();
    }
  }

  // Function to update existing user documents with FCM token
  Future<void> updateUserDocuments() async {
    final users = await _firestore.collection('users').get();
    for (var user in users.docs) {
      final data = user.data();
      if (!data.containsKey('fcmToken')) {
        String? fcmToken = await _fcm.getToken();
        await user.reference.update({
          'fcmToken': fcmToken,
        });
      }
    }
  }
}
