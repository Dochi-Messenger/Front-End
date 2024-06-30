import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  Future<Map<String, String>> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username') ?? '',
      'name': prefs.getString('name') ?? '',
      'unit': prefs.getString('unit') ?? '',
      'm_rank': prefs.getString('m_rank') ?? '',
      'profile_img': prefs.getString('profile_img') ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final profile = snapshot.data!;
            return Column(
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profile['profile_img']!.isNotEmpty
                      ? NetworkImage(profile['profile_img']!)
                      : AssetImage('assets/images/account.png') as ImageProvider,
                ),
                SizedBox(height: 20),
                Text('이름: ${profile['name']}'),
                Text('아이디: ${profile['username']}'),
                Text('소속부대: ${profile['unit']}'),
                Text('계급: ${profile['m_rank']}'),
              ],
            );
          }
        },
      ),
    );
  }
}
