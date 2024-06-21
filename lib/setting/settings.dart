import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../login/login.dart';
import 'user_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<String> uploadProfileImage(XFile image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(File(image.path));
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserData();
      print('fetchUserData called in initState');
    });
  }

  void _showEditNameDialog(BuildContext context, UserProvider userProvider) {
    final TextEditingController nameController =
        TextEditingController(text: userProvider.userName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('이름 변경'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: '새 이름',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                userProvider.updateUserName(nameController.text);
                Navigator.of(context).pop();
              },
              child: const Text('변경'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: userProvider.user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: userProvider.profileImageUrl !=
                                    null
                                ? NetworkImage(userProvider.profileImageUrl!)
                                : null,
                            child: userProvider.profileImageUrl == null
                                ? const Icon(Icons.add_a_photo, size: 50)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(
                                    source: ImageSource.gallery);

                                if (pickedFile != null) {
                                  String newImageUrl =
                                      await uploadProfileImage(pickedFile);
                                  userProvider.updateProfileImage(newImageUrl);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '닉네임: ${userProvider.userName ?? 'Unknown'}',
                                style: const TextStyle(fontSize: 18),
                              ),
                              TextButton(
                                onPressed: () {
                                  _showEditNameDialog(context, userProvider);
                                },
                                child: const Text(
                                  '변경',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '이메일: ${userProvider.user?.email ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '부서: ${userProvider.department ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('알림'),
                    value: userProvider.notificationsEnabled,
                    onChanged: (bool value) {
                      userProvider.updateNotificationsEnabled(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // 로그아웃 시 사용자 데이터 초기화 후 로그인 페이지로 이동
                      userProvider.clearUserData();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text('로그아웃'),
                  ),
                ],
              ),
            ),
    );
  }
}
