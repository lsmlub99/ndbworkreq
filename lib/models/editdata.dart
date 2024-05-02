import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditData {
  final User? user;

  EditData(this.user);

  Future<void> publishPost(
      String title, String content, List<File> imageFiles) async {
    if (user == null) {
      // 로그인되지 않은 경우 처리
      throw Exception('로그인되지 않았습니다.');
    }

    // 사용자 정보 가져오기
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.email)
        .get();
    if (!userSnapshot.exists) {
      // 사용자 정보를 찾을 수 없는 경우 처리
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    String? nickname = userSnapshot['nickname'];

    List<String> imageUrls = [];

    // 이미지 업로드를 병렬처리
    for (File file in imageFiles) {
      Reference storageReference = FirebaseStorage.instance.ref().child(
          'images/${DateTime.now().millisecondsSinceEpoch}_${user!.uid}.jpg');
      UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.whenComplete(() async {
        // 이미지 업로드가 완료된 후 이미지 URL을 가져와서 리스트에 추가
        String imageUrl = await storageReference.getDownloadURL();
        imageUrls.add(imageUrl);
      });
    }

    // Firestore에 게시글 데이터 저장
    await FirebaseFirestore.instance.collection('posts').add({
      'title': title,
      'content': content,
      'author_uid': user!.email,
      'author_nickname': nickname,
      'image_urls': imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
