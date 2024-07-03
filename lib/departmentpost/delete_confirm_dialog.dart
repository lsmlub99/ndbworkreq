import 'package:flutter/material.dart';
import 'boarddataprovider.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String postId;
  final String department;
  final BoardDataProvider provider;

  const DeleteConfirmationDialog({
    Key? key,
    required this.postId,
    required this.department,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('게시글 삭제'),
      content: const Text('정말로 이 게시글을 삭제하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            await provider.deletePost(postId);
            Navigator.of(context).pop();
          },
          child: const Text('삭제'),
        ),
      ],
    );
  }
}
