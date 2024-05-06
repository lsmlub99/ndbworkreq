import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const ExpandableText({Key? key, required this.text, this.style})
      : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style,
          maxLines: _expanded ? null : 3,
          overflow: TextOverflow.ellipsis,
        ),
        if (_isExpandable(widget.text)) // 텍스트가 3줄 이상이면 버튼 표시
          TextButton(
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Text(
              _expanded ? '접기' : '더 보기',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }

  bool _isExpandable(String text) {
    TextPainter painter = TextPainter(
      text: TextSpan(text: text),
      maxLines: 3, // 텍스트의 최대 라인 수를 정의
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);

    return painter.didExceedMaxLines;
  }
}
