import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'boarddataprovider.dart';
import 'post_card.dart';
import '../editpage/editpage.dart';

class DepartmentPostsPage extends StatefulWidget {
  final String department;

  const DepartmentPostsPage({Key? key, required this.department})
      : super(key: key);

  @override
  _DepartmentPostsPageState createState() => _DepartmentPostsPageState();
}

class _DepartmentPostsPageState extends State<DepartmentPostsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<BoardDataProvider>(context, listen: false);
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await provider.fetchCurrentUserDepartment(user.email!);
      }
      provider.getPostsStreamForDepartment(widget.department);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.department} 게시글'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final User? currentUser = userSnapshot.data;

          return Consumer<BoardDataProvider>(
            builder: (context, provider, _) {
              if (provider.postsStream == null) {
                return const Center(child: Text('부서를 선택해주세요.'));
              }

              return StreamBuilder<QuerySnapshot>(
                stream: provider.postsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final posts = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final postData =
                          posts[index].data() as Map<String, dynamic>;
                      final String postId = snapshot.data!.docs[index].id;
                      final String authorUid = postData['userId'] ?? '';

                      return PostCard(
                        postData: postData,
                        postId: postId,
                        authorUid: authorUid,
                        currentUser: currentUser,
                      );
                    },
                  );
                },
              );
            },
          );
        },
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
