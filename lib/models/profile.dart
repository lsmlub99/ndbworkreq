import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String nickname;
  final String? department; // 부서 정보 추가

  UserProfile({required this.userId, required this.nickname, this.department});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nickname': nickname,
      'department': department, // 부서 정보 추가
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
