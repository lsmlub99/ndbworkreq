import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/boarddata.dart';
import 'editpage.dart';
import '../boardfunction/imagedetailscreen.dart';
import '../boardfunction/expandaletext.dart';

class DepartmentPostsPage extends StatefulWidget {
  final String department;

  const DepartmentPostsPage({Key? key, required this.department})
      : super(key: key);

  @override
  _DepartmentPostsPageState createState() => _DepartmentPostsPageState();
}

class _DepartmentPostsPageState extends State<DepartmentPostsPage> {
  Map<String, int> _currentPageMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.department} 부서 게시글'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: BoardData.getPostsStreamForDepartment(widget.department),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final posts = snapshot.data!.docs;
          final User? currentUser = FirebaseAuth.instance.currentUser;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postData = posts[index].data() as Map<String, dynamic>;
              final String postId = snapshot.data!.docs[index].id;
              final String authorUid = postData['author_uid'];

              final timestamp = postData['timestamp'];
              String timestampString = 'Unknown';

              if (timestamp != null && timestamp is Timestamp) {
                timestampString = timestamp.toDate().toString();
              }

              List<String> imageUrls =
                  List<String>.from(postData['image_urls']);

              int currentPage = _currentPageMap[postId] ?? 0;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CarouselSlider(
                                  options: CarouselOptions(
                                    height: 200,
                                    enlargeCenterPage: true,
                                    enableInfiniteScroll: false,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        _currentPageMap[postId] = index;
                                      });
                                    },
                                    initialPage: currentPage,
                                  ),
                                  items: imageUrls.map((imageUrl) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Hero(
                                          tag: imageUrl,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ImageDetailScreen(
                                                    imageUrls: imageUrls,
                                                    initialIndex: imageUrls
                                                        .indexOf(imageUrl),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${currentPage + 1}/${imageUrls.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          postData['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          child: ExpandableText(
                            text: postData['content'],
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          '작성자: ${postData['author_nickname']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          '작성일: ${timestampString}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      if (currentUser != null && currentUser.uid == authorUid)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _confirmDelete(
                                  context, postId, widget.department);
                            },
                            child: const Text('삭제'),
                          ),
                        ),
                    ],
                  ),
                ),
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

  void _confirmDelete(BuildContext context, String postId, String department) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게시물 삭제'),
          content: const Text('정말로 이 게시물을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                BoardData.deletePost(postId, department);
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
