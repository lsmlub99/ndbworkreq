import 'package:flutter/material.dart';
import '../login/login.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 로그아웃 후 다시 로그인 페이지로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text('로그아웃'),
        ),
      ),
    );
  }
}
