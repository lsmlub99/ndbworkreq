import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart'; // 로그인 페이지를 import 해주세요

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController(); // 이메일 입력 컨트롤러
  final passController = TextEditingController(); // 비밀번호 입력 컨트롤러
  final confirmPassController = TextEditingController(); // 비밀번호 확인 입력 컨트롤러
  String errorString = ''; // 회원가입 에러 메시지

  // Firebase Auth 회원가입 함수
  void fireAuthSignUp(BuildContext context) async {
    try {
      if (passController.text != confirmPassController.text) {
        setState(() {
          errorString = '비밀번호가 일치하지 않습니다.';
        });
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passController.text);
      print("User signed up: ${userCredential.user}");

      // 회원가입 성공 시 로그인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorString = e.message!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                fireAuthSignUp(context); // 회원가입 버튼 클릭
              },
              child: const Text(
                '회원가입',
                style: TextStyle(fontSize: 18), // 버튼 폰트 크기 조정
              ),
            ),
            const SizedBox(height: 20),
            Text(
              errorString,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16, // 에러 텍스트 폰트 크기 조정
              ),
            ),
          ],
        ),
      ),
    );
  }
}
