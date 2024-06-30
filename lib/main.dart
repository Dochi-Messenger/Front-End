import 'package:flutter/material.dart';
import 'package:dochi2/screens/sign_in.dart';
import 'package:dochi2/screens/main_page.dart';
import 'package:dochi2/screens/chat_rooms_page.dart';
import 'package:dochi2/screens/chat_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My New Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // 초기 화면을 로그인 화면으로 설정
      routes: {
        '/main': (context) => MainPage(),
        '/chat_rooms': (context) => ChatRoomsPage(),
        '/chat_messages': (context) => ChatMessagesPage(roomName: ''), // 기본 roomName으로 빈 문자열 설정
      },
    );
  }
}
