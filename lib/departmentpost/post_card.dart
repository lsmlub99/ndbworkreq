import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'boarddataprovider.dart';
import '../boardfunction/imagedetailscreen.dart';
import '../boardfunction/expandabletext.dart';
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
    final provider = Provider.of<BoardDataProvider>(context);
    final timestamp = postData['timestamp'];
    String timestampString = 'Unknown';

    if (timestamp != null && timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      timestampString = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    }

    List<String> imageUrls = List<String>.from(postData['image_urls']);
    String department = postData['department'];
    int currentPage = provider.getCurrentPage(department, postId);

    bool canViewAndEdit = provider.currentUserDepartment == department;

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
            // 게시글 작성자 정보 표시
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '작성자: ${postData['nickname']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '부서: $department',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
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
                            provider.setCurrentPage(department, postId, index);
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
                  Text(
                    postData['status'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: getStatusTextColor(postData['status']),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: canViewAndEdit
                  ? Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            provider.updatePostStatus(postId, '접수중');
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                return postData['status'] == '접수중'
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.secondary;
                              },
                            ),
                          ),
                          child: Text(
                            '접수중',
                            style: TextStyle(
                              color: postData['status'] == '접수중'
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            provider.updatePostStatus(postId, '처리중');
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                return postData['status'] == '처리중'
                                    ? Colors.orange
                                    : Theme.of(context).colorScheme.secondary;
                              },
                            ),
                          ),
                          child: Text(
                            '처리중',
                            style: TextStyle(
                              color: postData['status'] == '처리중'
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            provider.updatePostStatus(postId, '완료');
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                return postData['status'] == '완료'
                                    ? Colors.blue
                                    : Theme.of(context).colorScheme.secondary;
                              },
                            ),
                          ),
                          child: Text(
                            '완료',
                            style: TextStyle(
                              color: postData['status'] == '완료'
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            if (currentUser!.uid == authorUid)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DeleteConfirmationDialog(
                          postId: postId,
                          department: department,
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

  Color getStatusTextColor(String status) {
    switch (status) {
      case '접수중':
        return Colors.green;
      case '처리중':
        return Colors.orange;
      case '완료':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}
