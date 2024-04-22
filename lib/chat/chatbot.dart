import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result.dart';

const apiKey = '';
const apiUrl = 'https://api.openai.com/v1/completions';

Future<String> generateText(String prompt) async {
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey'
      },
      body: jsonEncode({
        "model": "text-davinci-003",
        'prompt': prompt,
        'max_tokens': 1000,
        'temperature': 0,
        'top_p': 1,
        'frequency_penalty': 0,
        'presence_penalty': 0
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> newResponse =
          jsonDecode(utf8.decode(response.bodyBytes));

      if (newResponse.containsKey('choices') &&
          newResponse['choices'].isNotEmpty) {
        return newResponse['choices'][0]['text'];
      } else {
        throw Exception('No response text found.');
      }
    } else {
      throw Exception(
          'Failed to load response. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error during API request: $e');
    rethrow; // 예외를 다시 throw하여 상위 코드에서 처리할 수 있도록 함
  }
}

class ChatBotPage extends StatelessWidget {
  const ChatBotPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        home: FirstPage(), debugShowCheckedModeBanner: false);
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("\n   이건 뭐야?"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '궁금하신 부분은 여기에 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    String prompt = _controller.text;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ResultPage(prompt)));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
