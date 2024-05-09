import 'package:flutter/material.dart';

import 'package:flutter_try/chat/chatbot.dart';
import '../setting/settings.dart';

import 'home_page.dart';

class NBoard extends StatefulWidget {
  const NBoard({Key? key}) : super(key: key);

  @override
  State<NBoard> createState() => _NBoardState();
}

class _NBoardState extends State<NBoard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ndb 해주세요'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomePage(), // 홈 화면
          ChatBotPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.blue, // 선택된 탭의 텍스트 색상 변경
          onTap: (int index) {
            // 탭을 눌렀을 때 동작 설정
            if (index == 0) {
              // 게시판 탭을 눌렀을 때
              _tabController.animateTo(0); // 홈 화면으로 이동
            }
          },
          tabs: const [
            Tab(
              icon: Icon(Icons.person),
              text: "게시판",
            ),
            Tab(
              icon: Icon(Icons.chat),
              text: "챗봇",
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: "설정",
            ),
          ],
        ),
      ),
    );
  }
}
