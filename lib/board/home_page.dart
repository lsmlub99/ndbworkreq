import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/boarddataprovider.dart';
import '../departmentpost/departmentpostpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedDepartment;

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
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _selectedDepartment,
              hint: const Text('부서 선택'),
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDepartment = newValue;
                  if (newValue != null) {
                    Provider.of<BoardDataProvider>(context, listen: false)
                        .getPostsStreamForDepartment(newValue);
                  }
                });
              },
              items:
                  _departmentList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              style: const TextStyle(color: Colors.black),
              elevation: 2,
              underline: Container(
                height: 1,
                color: Colors.grey,
              ),
              dropdownColor: Colors.white,
            ),
          ),
        ],
      ),
      body: _selectedDepartment == null
          ? const Center(child: Text('부서를 선택해주세요.'))
          : DepartmentPostsPage(department: _selectedDepartment!),
    );
  }
}
