import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String nickname;
  final String? department;
  final String? profileImageUrl; // 프로필 이미지 URL 추가

  UserProfile({
    required this.userId,
    required this.nickname,
    this.department,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nickname': nickname,
      'department': department,
      'profileImageUrl': profileImageUrl, // 프로필 이미지 URL 추가
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
