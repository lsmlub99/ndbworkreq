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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 100), // 추가된 부분: 상단에 간격 추가
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40), // 이미지 좌우에 여백 추가
                child: Image.asset(
                  'images/ndb.jpg',
                  width: 250, // 이미지의 가로 길이
                  height: 250, // 이미지의 세로 길이
                  fit: BoxFit.contain, // 이미지가 차지할 공간을 채우는 방법
                ),
              ),
              const SizedBox(height: 20), // 이미지와 텍스트 상자 간 간격 추가
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20), // 텍스트 상자 좌우에 여백 추가
                child: Text(
                  "로그인",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10), // 텍스트 상자와 입력 상자 간 간격 추가
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20), // 입력 상자 좌우에 여백 추가
                child: TextField(
                  controller: emailContoller,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10), // 입력 상자들 간 간격 추가
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20), // 입력 상자 좌우에 여백 추가
                child: TextField(
                  controller: passController,
                  obscureText: true, // 비밀번호 입력 시 보이지 않도록 설정
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20), // 입력 상자와 버튼 간 간격 추가
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20), // 버튼 좌우에 여백 추가
                child: ElevatedButton(
                  onPressed: () => fireAuthLogin(context),
                  child: const Text("Login"),
                ),
              ),
              const SizedBox(height: 10), // 버튼과 회원가입 간 간격 추가
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20), // 버튼 좌우에 여백 추가
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupPage()),
                    );
                  },
                  child: const Text("회원가입"),
                ),
              ),
              const SizedBox(height: 20), // 추가된 부분: 하단에 간격 추가
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  errorString,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 20), // 추가된 부분: 에러 메시지와 하단 간 간격 추가
            ],
          ),
        ),
      ),
    );
  }
}
