import 'package:flutter/material.dart';
import 'departmentpostpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedDepartment;

  // 부서 목록
  final List<String> _departmentList = [
    '원무과',
    '시설팀',
    '전산팀',
    '영양팀',
    '구매총무팀',
    '심사팀',
    '재무회계인사팀',
    '의무기록팀',
    '기획홍보팀'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            // 홈으로 이동하는 기능 추가
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        actions: [
          // 드롭다운 버튼을 추가합니다.
          DropdownButton<String>(
            value: _selectedDepartment,
            hint: const Text('부서 선택'),
            icon: const Icon(Icons.arrow_drop_down),
            onChanged: (String? newValue) {
              setState(() {
                _selectedDepartment = newValue;
              });
            },
            items:
                _departmentList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            // 테두리 스타일 설정
            style: const TextStyle(color: Colors.black), // 드롭다운 버튼의 텍스트 색상
            elevation: 2, // 드롭다운 메뉴의 음영 높이
            underline: Container(
              // 드롭다운 버튼 테두리
              height: 1,
              color: Colors.grey, // 테두리 선 색상
            ),
            dropdownColor: Colors.white, // 드롭다운 메뉴의 배경색
          ),
        ],
      ),
      body: _selectedDepartment == null
          ? const Center(
              child: Text(
                '부서를 선택해주세요.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : DepartmentPostsPage(
              department: _selectedDepartment! // 선택된 부서의 게시판을 보여줍니다.
              ),
    );
  }
}
