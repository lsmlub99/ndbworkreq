import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/boarddata.dart'; // boarddata.dart 파일을 import합니다.

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: BoardData.getPostsStream(), // BoardData 클래스에서 데이터를 가져옵니다.
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

            // 게시물에 업로드된 이미지 URL 가져오기
            List<String> imageUrls = List<String>.from(postData['image_urls']);

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
                    if (postData['image_urls'] != null)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageUrls.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(
                                imageUrls[i], // 업로드된 이미지 URL 사용
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
                        '작성자: ${postData['author_nickname']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '작성일: ${timestampString}',
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
  }
}
