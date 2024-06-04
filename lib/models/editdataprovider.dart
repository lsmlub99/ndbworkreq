import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDataProvider extends ChangeNotifier {
  final User? user;
  String? _selectedDepartment; // Modified
  final List<String> _departments = [
    // Modified
    '원무과',
    '시설팀',
    '전산팀',
    '영양팀',
    '구매총무팀',
    '심사팀',
    '재무회계인사팀',
    '의무기록팀',
    '기획홍보팀'
  ];

  EditDataProvider(this.user);

  String? get selectedDepartment => _selectedDepartment;
  set selectedDepartment(String? department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  List<String> get departments => _departments; // Modified

  Future<void> publishPost(String title, String content, List<File> imageFiles,
      String department) async {
    if (user == null) {
      throw Exception('로그인되지 않았습니다.');
    }

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email)
        .get();
    if (!userSnapshot.exists) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    String? nickname = userSnapshot['nickname'];

    List<String> imageUrls = [];

    for (File file in imageFiles) {
      Reference storageReference = FirebaseStorage.instance.ref().child(
          'images/${DateTime.now().millisecondsSinceEpoch}_${user!.uid}.jpg');
      UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.whenComplete(() async {
        String imageUrl = await storageReference.getDownloadURL();
        imageUrls.add(imageUrl);
      });
    }

    await FirebaseFirestore.instance
        .collection('departments')
        .doc(department)
        .collection('posts')
        .add({
      'title': title,
      'content': content,
      'userId': user!.email,
      'nickname': nickname,
      'image_urls': imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
      'status': '접수중',
    });

    // 데이터 변경 후에 리스너들에게 알림
    notifyListeners();
  }
}
