import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/editdata.dart';
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
  final EditData _editData = EditData(FirebaseAuth.instance.currentUser);

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
    try {
      String title = _titleController.text.trim();
      String content = _contentController.text.trim();

      if (title.isEmpty || content.isEmpty) {
        // 제목 또는 내용이 비어있는 경우 처리
        throw Exception('제목과 내용을 입력해주세요.');
      }

      // 이미지 업로드 중임을 사용자에게 알리기 위해 인디케이터 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // 이미지 업로드
      await _editData.publishPost(title, content, _imageFiles);

      // 인디케이터 닫기
      Navigator.of(context).pop();

      // 게시글 추가 후 이전 화면으로 이동
      Navigator.of(context).pop();
    } catch (e) {
      // 오류 발생 시 알림 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('오류'),
            content: Text(e.toString()),
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
    }
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
