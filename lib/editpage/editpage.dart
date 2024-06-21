import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'editdataprovider.dart';
import 'package:reorderables/reorderables.dart';

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
  late EditDataProvider _editDataProvider;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _editDataProvider = EditDataProvider(_user);
  }

  void _publishPost() async {
    try {
      String title = _titleController.text.trim();
      String content = _contentController.text.trim();

      if (title.isEmpty ||
          content.isEmpty ||
          _editDataProvider.selectedDepartment == null) {
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

      await _editDataProvider.publishPost(
          title, content, _imageFiles, _editDataProvider.selectedDepartment!);

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
              if (_imageFiles.isNotEmpty)
                Column(
                  children: [
                    CarouselSlider.builder(
                      itemCount: _imageFiles.length,
                      itemBuilder: (context, index, realIndex) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 5.0,
                                    spreadRadius: 1.0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.file(
                                  _imageFiles[index],
                                  fit: BoxFit.cover,
                                  width: 1000.0,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  '${index + 1} / ${_imageFiles.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      options: CarouselOptions(
                        autoPlay: false,
                        enlargeCenterPage: true,
                        aspectRatio: 2.0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ReorderableWrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      padding: const EdgeInsets.all(8),
                      children: _imageFiles.asMap().entries.map((entry) {
                        int index = entry.key;
                        File imageFile = entry.value;
                        return Container(
                          key: ValueKey(index),
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.file(
                                  imageFile,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final File item = _imageFiles.removeAt(oldIndex);
                          _imageFiles.insert(newIndex, item);
                        });
                      },
                    ),
                  ],
                )
              else
                const Text('이미지를 선택해주세요.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getImage,
                child: const Text('이미지 선택'),
              ),
              const SizedBox(height: 20),
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
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: '내용',
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) {
                  if (text.length % 30 == 0) {
                    _contentController.text += '\n';
                  }
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _editDataProvider.selectedDepartment,
                decoration: const InputDecoration(
                  labelText: '부서 선택',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _editDataProvider.selectedDepartment = value;
                  });
                },
                items: _editDataProvider.departments.map((department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
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
