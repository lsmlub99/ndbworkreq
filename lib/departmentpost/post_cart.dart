import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/boarddataprovider.dart';
import '../boardfunction/imagedetailscreen.dart';
import '../boardfunction/expandaletext.dart';
import 'delete_confirm_dialog.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> postData;
  final String postId;
  final String authorUid;
  final User? currentUser;

  const PostCard({
    Key? key,
    required this.postData,
    required this.postId,
    required this.authorUid,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BoardDataProvider>(context, listen: false);
    final timestamp = postData['timestamp'];
    String timestampString = 'Unknown';

    if (timestamp != null && timestamp is Timestamp) {
      timestampString = timestamp.toDate().toString();
    }

    List<String> imageUrls = List<String>.from(postData['image_urls']);
    int currentPage = provider.getCurrentPage(postId);

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
                            provider.setCurrentPage(postId, index);
                          },
                          initialPage: currentPage,
                        ),
                        items: imageUrls.map((imageUrl) {
                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageDetailScreen(
                                        imageUrls: imageUrls,
                                        initialIndex:
                                            imageUrls.indexOf(imageUrl),
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: ExpandableText(
                text: postData['content'],
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Text(
                '작성자: ${postData['nickname']}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Text(
                '작성일: $timestampString',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Row(
                children: [
                  const Text(
                    '진행상황: ',
                    style: TextStyle(fontSize: 14),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          provider.updatePostStatus(postId, '접수중');
                        },
                        child: const Text('접수중'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          provider.updatePostStatus(postId, '처리중');
                        },
                        child: const Text('처리중'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          provider.updatePostStatus(postId, '완료');
                        },
                        child: const Text('완료'),
                      ),
                    ],
                  )
                ],
              ),
            ),
            if (currentUser!.email == authorUid)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DeleteConfirmationDialog(
                          postId: postId,
                          provider: provider,
                        );
                      },
                    );
                  },
                  child: const Text('삭제'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
