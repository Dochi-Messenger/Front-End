import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_friend_page.dart';
import 'package:dochi2/screens/chat_screen.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  String _name = '';
  String _unit = '';
  List _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadContacts();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('http://172.20.10.2:5001/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _name = data['name'];
        _unit = data['unit'];
      });
    } else {
      print('Failed to load profile: ${jsonDecode(response.body)['error']}');
    }
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('http://172.20.10.2:5001/contacts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _contacts = data;
      });
    } else {
      print('Failed to load contacts: ${jsonDecode(response.body)['error']}');
    }
  }

  Future<void> _startChat(int contactId) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    final response = await http.post(
      Uri.parse('http://172.20.10.2:5001/start_chat'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'contact_user_id': contactId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatMessagesPage(roomName: data['room_name']),
        ),
      );
    } else {
      print('Failed to start chat: ${jsonDecode(response.body)['error']}');
    }
  }

  void _addFriend() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFriendPage()),
    );
    if (result == true) {
      _loadContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _addFriend,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('내 프로필', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('이름: $_name'),
            Text('소속: $_unit'),
            Divider(),
            Text('연락처', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return ListTile(
                    title: Text(contact['name']),
                    subtitle: Text(contact['unit']),
                    trailing: IconButton(
                      icon: Icon(Icons.chat),
                      onPressed: () {
                        _startChat(contact['id']);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
