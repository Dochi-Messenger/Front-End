import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddFriendPage extends StatefulWidget {
  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _militaryIdController = TextEditingController();
  String _accessToken = '';

  @override
  void initState() {
    super.initState();
    _loadAccessToken();
  }

  Future<void> _loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('accessToken') ?? '';
    });
  }

  Future<void> _addFriend() async {
    final response = await http.post(
      Uri.parse('http://172.16.0.237:5001/contact_add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode({
        'name': _nameController.text,
        'military_id': _militaryIdController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact added successfully')),
      );
      Navigator.pop(context, true);  // 페이지를 닫고 이전 페이지로 돌아감
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['error'] ?? 'Failed to add contact')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _militaryIdController,
              decoration: InputDecoration(labelText: 'Military ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addFriend,
              child: Text('Add Friend'),
            ),
          ],
        ),
      ),
    );
  }
}
