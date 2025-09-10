import 'package:flutter/material.dart';
import 'package:frontend/User/screens/auth/signup/signup_screen.dart';
import 'package:frontend/User/screens/homepage/HomePage.dart';
import 'package:frontend/Admin/list_of_questions/pages/question_home_page.dart';
import 'package:frontend/Admin/homepage/AminHomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignupScreen(),
      title: 'Quản lý câu hỏi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF5AA6FF), // xanh chủ đạo (như ảnh)
        scaffoldBackgroundColor: const Color(0xFFF8FAFF),
        fontFamily: 'Roboto',
      ),
      // home: const AdminHomePage(),
    );
  }
}
