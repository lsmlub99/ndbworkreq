import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditData {
  final User? user;

  EditData(this.user);

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
      'author_uid': user!.email,
      'author_nickname': nickname,
      'image_urls': imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
