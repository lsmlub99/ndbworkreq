import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String nickname,
    required String? department,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await saveUserProfile(UserProfile(
        userId: userCredential.user!.email!,
        nickname: nickname,
        department: department,
      ));
    } catch (e) {
      throw e;
    }
  }

  Future<void> saveUserProfile(UserProfile userProfile) async {
    try {
      await _firestore.collection('users').doc(userProfile.userId).set({
        'nickname': userProfile.nickname,
        'department': userProfile.department,
      });
    } catch (e) {
      throw e;
    }
  }
}
