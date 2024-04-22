import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../board/nboard.dart';
import 'signup.dart'; // 회원가입 페이지를 import 해주세요

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailContoller = TextEditingController(); // email 입력 컨트롤러
  final passController = TextEditingController(); // password 입력 컨트롤러
  String errorString = ''; // login error 보려고 만든 String state

  // Firebase auth login 함수, 이메일 + 비번으로 로그인
  void fireAuthLogin(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailContoller.text, password: passController.text);
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NBoard()),
        );
      }
    } catch (error) {
      setState(() {
        errorString = '이메일이나 비밀번호를 확인해주세요.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeFirebase(); // Firebase 초기화 함수 호출
  }

  // Firebase 초기화 함수
  void initializeFirebase() async {
    await Firebase.initializeApp();
  }

  @override
  void dispose() {
    emailContoller.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Text(
                "로그인",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emailContoller,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: passController,
                obscureText: true, // 비밀번호 입력 시 보이지 않도록 설정
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: ElevatedButton(
                onPressed: () => fireAuthLogin(context),
                child: const Text("Login"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                errorString,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupPage()),
                      );
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 20),
                  /*Image.asset(
                    'assets/images/123.png',
                    width: 100, // 이미지의 가로 길이
                    height: 100, // 이미지의 세로 길이
                    fit: BoxFit.cover, // 이미지가 차지할 공간을 채우는 방법
                  ),*/
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
