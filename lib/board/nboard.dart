import 'package:flutter/material.dart';
import 'editpage.dart';
import 'package:flutter_try/chat/chatbot.dart';
import '../setting/settings.dart';
import 'departmentpostpage.dart';
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "부서",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            // 부서 목록 버튼 생성
            for (var department in [
              '원무과',
              '시설팀',
              '전산팀',
              '영양팀',
              '구매총무팀',
              '심사팀',
              '재무회계인사팀',
              '의무기록팀',
              '기획홍보팀'
            ])
              ListTile(
                title: Text(department),
                onTap: () {
                  // 각 부서의 게시글을 보여주는 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DepartmentPostsPage(department: department),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomePage(), // HomePage 위젯을 불러옵니다.
          ChatBotPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
