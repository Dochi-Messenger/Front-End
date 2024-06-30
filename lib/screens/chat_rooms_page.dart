import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatRoomsPage extends StatefulWidget {
  @override
  _ChatRoomsPageState createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  List _chatRooms = [];

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('http://172.20.10.2:5001/chat_rooms'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _chatRooms = data;
      });
    } else {
      print('Failed to load chat rooms: ${jsonDecode(response.body)['error']}');
    }
  }

  void _navigateToChatMessages(String roomName) {
    Navigator.pushNamed(context, '/chat_messages', arguments: roomName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Rooms'),
      ),
      body: ListView.builder(
        itemCount: _chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = _chatRooms[index];
          return ListTile(
            title: Text(chatRoom['name']),
            onTap: () => _navigateToChatMessages(chatRoom['name']),
          );
        },
      ),
    );
  }
}
