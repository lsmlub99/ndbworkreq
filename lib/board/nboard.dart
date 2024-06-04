import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:flutter_try/chat/chatbot.dart';
import '../setting/settings.dart';

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
          labelColor: Colors.blue,
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
