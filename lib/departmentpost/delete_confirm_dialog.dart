import 'package:flutter/material.dart';
import 'boarddataprovider.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String postId;
  final BoardDataProvider provider;

  const DeleteConfirmationDialog({
    Key? key,
    required this.postId,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            provider.deletePost(postId, provider.department!);
            Navigator.of(context).pop();
          },
          child: const Text('확인'),
        ),
      ],
    );
  }
}
