import 'package:flutter/material.dart';
import 'editpage.dart'; // 새로운 게시글을 작성하기 위한 페이지를 import합니다.

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'), // 홈 화면을 나타내는 제목입니다.
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '어서오세요!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '이곳은 게시판 앱의 홈 화면입니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditPage()),
                );
              },
              child: const Text('새로운 게시글 작성하기'),
            ),
          ],
        ),
      ),
    );
  }
}
