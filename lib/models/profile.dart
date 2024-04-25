import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String nickname;

  UserProfile({required this.userId, required this.nickname});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nickname': nickname,
    };
  }
}

Future<void> saveUserProfile(UserProfile userProfile) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userProfile.userId)
        .set(userProfile.toMap());
  } catch (e) {
    print('Failed to save user profile: $e');
    throw Exception('Failed to save user profile');
  }
}
