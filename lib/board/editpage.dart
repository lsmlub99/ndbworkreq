import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPage extends StatefulWidget {
  const EditPage({Key? key}) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  User? _user;
  List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  void _publishPost() async {
    if (_user == null) {
      // 로그인되지 않은 경우 처리
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('로그인 오류'),
            content: const Text('게시글을 작성하려면 먼저 로그인하세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      // 제목 또는 내용이 비어있는 경우 처리
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('입력 오류'),
            content: const Text('제목과 내용을 입력해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.email)
        .get()
        .then((userSnapshot) async {
      if (!userSnapshot.exists) {
        // 사용자 정보를 찾을 수 없는 경우 처리
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('오류'),
              content: const Text('사용자 정보를 찾을 수 없습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
        return;
      }

      String? nickname = userSnapshot['nickname'];

      List<String> imageUrls = [];

      // 이미지 업로드를 직렬로 처리
      for (File file in _imageFiles) {
        Reference storageReference = FirebaseStorage.instance.ref().child(
            'images/${DateTime.now().millisecondsSinceEpoch}_${_user!.uid}.jpg');
        UploadTask uploadTask = storageReference.putFile(file);
        await uploadTask.whenComplete(() async {
          // 이미지 업로드가 완료된 후 이미지 URL을 가져와서 리스트에 추가
          String imageUrl = await storageReference.getDownloadURL();
          imageUrls.add(imageUrl);
        });
      }

      // Firestore에 게시글 데이터 저장
      FirebaseFirestore.instance.collection('posts').add({
        'title': title,
        'content': content,
        'author_uid': _user!.email,
        'author_nickname': nickname,
        'image_urls': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        // 게시글 추가 후 이전 화면으로 이동
        Navigator.of(context).pop();
      });
    });
  }

  void _getImage() async {
    final picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    setState(() {
      if (pickedFiles != null) {
        _imageFiles = pickedFiles.map((file) => File(file.path)).toList();
      } else {
        print('No images selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 작성'),
        actions: [
          TextButton(
            onPressed: _publishPost,
            child: const Text(
              '게시',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '제목',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _contentController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: '내용',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_imageFiles.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, index) {
                    return Image.file(
                      _imageFiles[index],
                      fit: BoxFit.cover,
                    );
                  },
                )
              else
                const Text('이미지를 선택해주세요.'),
              ElevatedButton(
                onPressed: _getImage,
                child: const Text('이미지 선택'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _publishPost,
        tooltip: '게시하기',
        child: const Icon(Icons.send),
      ),
    );
  }
}
