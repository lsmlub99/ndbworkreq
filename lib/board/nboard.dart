import 'package:flutter/material.dart';
import 'editpage.dart';
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
            ListTile(
              title: const Text("전산"),
              onTap: () {
                // '전산' 부서의 게시글을 보여주는 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const DepartmentPostsPage(department: "전산")),
                );
              },
            ),
            ListTile(
              title: const Text("구매"),
              onTap: () {
                // '구매' 부서의 게시글을 보여주는 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const DepartmentPostsPage(department: "구매")),
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

class DepartmentPostsPage extends StatelessWidget {
  final String department;

  const DepartmentPostsPage({Key? key, required this.department})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 해당 부서에 대한 게시글을 필터링하거나 가져오는 코드를 추가할 수 있습니다.

    return Scaffold(
      appBar: AppBar(
        title: Text('$department 부서 게시글'),
      ),
      body: Center(
        child: Text('이 페이지에서 $department 부서 게시글을 보여줄 수 있습니다.'),
      ),
    );
  }
}
