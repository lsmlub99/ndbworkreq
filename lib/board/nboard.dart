import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editpage.dart'; // 게시글 추가 화면을 import 합니다.
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
            const ListTile(
              title: Text("전산"),
            ),
            const ListTile(
              title: Text("구매"),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomePage(),
          ChatBotPage(), // 챗봇 페이지 추가
          SettingsPage(), // 설정 페이지 추가
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
      // 플로팅 액션 버튼 추가
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 게시글 추가 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _userInfoFuture;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = _getUserInfo();
  }

  Future<Map<String, dynamic>> _getUserInfo() async {
    // 여기에 Firestore에서 유저 정보를 가져오는 코드를 추가하세요.
    // 예를 들어, FirebaseAuth 또는 그 외의 인증 메서드를 사용하여 유저 정보를 가져올 수 있습니다.
    // 여기서는 임시로 하드코딩된 데이터를 반환하도록 하겠습니다.
    await Future.delayed(const Duration(seconds: 2)); // 임시로 2초의 지연을 추가합니다.
    return {'nickname': 'junsanteam'}; // 임시 데이터
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final posts = snapshot.data!.docs;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final postData = posts[index].data() as Map<String, dynamic>;

            final timestamp = postData['timestamp'];
            String timestampString = 'Unknown';

            if (timestamp != null && timestamp is Timestamp) {
              timestampString = timestamp.toDate().toString();
            }

            return FutureBuilder<Map<String, dynamic>>(
              future: _userInfoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData) {
                  return const Text('Unknown');
                }

                final authorNickname = snapshot.data!['nickname'];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  'https://cdn.pixabay.com/photo/2015/06/19/20/13/sunset-815270_1280.jpg',
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            postData['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            postData['content'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '작성자: $authorNickname',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '작성일: ${timestamp.toDate().toString()}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
