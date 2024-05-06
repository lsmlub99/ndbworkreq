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
  String? selectedDepartment;
  final List<String> departments = [
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

      if (title.isEmpty || content.isEmpty || selectedDepartment == null) {
        throw Exception('제목, 내용, 부서를 선택해주세요.');
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await _editData.publishPost(
          title, content, _imageFiles, selectedDepartment!);

      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
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
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                decoration: const InputDecoration(
                  labelText: '부서 선택',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value;
                  });
                },
                items: departments.map((department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
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
