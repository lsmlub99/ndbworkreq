import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    // 사용자 로그인 상태 변경을 감지하는 리스너 추가
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  void _publishPost() {
    // 사용자가 로그인하지 않은 경우 에러 메시지 표시
    if (_user == null) {
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

    // 입력된 제목과 내용 가져오기
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();

    // 제목과 내용이 비어있는지 확인
    if (title.isEmpty || content.isEmpty) {
      // 비어있을 경우 경고창 표시
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

    // Firestore에서 사용자의 닉네임 가져오기
    FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.email)
        .get()
        .then((userSnapshot) {
      if (!userSnapshot.exists) {
        // 사용자 문서를 찾을 수 없는 경우 에러 메시지 표시
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

      // Firestore에 게시글 추가
      FirebaseFirestore.instance.collection('posts').add({
        'title': title,
        'content': content,
        'author_uid': _user!.email,
        'author_nickname': nickname, // 작성자의 닉네임 저장
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        // 게시글 추가 후 이전 화면으로 이동
        Navigator.of(context).pop();
      });
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
              maxLines: null, // 여러 줄 입력 가능하도록 설정
              decoration: const InputDecoration(
                hintText: '내용',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
