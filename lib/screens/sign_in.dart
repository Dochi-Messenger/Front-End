import 'package:flutter/material.dart';
import 'package:dochi2/screens/main_page.dart';
import 'package:dochi2/screens/sign_up.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAuthenticating = false;

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://172.20.10.2:5001/login'), // URL에서 공백 제거
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', data['access_token']);
      await prefs.setString('username', data['user']['username'] ?? '');
      await prefs.setString('name', data['user']['name'] ?? '');
      await prefs.setString('unit', data['user']['unit'] ?? '');
      await prefs.setString('m_rank', data['user']['m_rank'] ?? '');
      await prefs.setString('profile_img', data['user']['profile_img'] ?? '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 성공')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['error'] ?? '로그인 실패')),
      );
    }
  }

  Future<void> _authenticate() async {
    try {
      setState(() {
        _isAuthenticating = true;
      });

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: '생체 인식을 사용하여 로그인합니다.',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        _login();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('생체 인식에 실패했습니다.')),
      );
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: 430,
              height: 320,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.elliptical(50, 30),
                  bottomLeft: Radius.elliptical(50, 30),
                ),
                color: Color.fromRGBO(22, 141, 99, 1),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 120, top: 80),
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(100),
                ),
                color: Colors.white,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 155, top: 110),
              child: Image.asset(
                'assets/images/dochilogo.png',
                width: 80,
                height: 80,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 250),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DOCHI MESSENGER',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Regular',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 40, right: 40, top: 360),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: '군번',
                      filled: true,
                      fillColor: const Color.fromRGBO(233, 233, 233, 1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color.fromRGBO(177, 177, 177, 1),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 40),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      filled: true,
                      fillColor: const Color.fromRGBO(233, 233, 233, 1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color.fromRGBO(177, 177, 177, 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(22, 141, 99, 1),
                    minimumSize: const Size(300, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _login,
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(22, 141, 99, 1),
                    minimumSize: const Size(300, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _authenticate,
                  child: const Text(
                    '생체 인식으로 로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(
                        color: Color.fromRGBO(22, 141, 99, 1),
                      ),
                      backgroundColor: Colors.white,
                      minimumSize: const Size(300, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromRGBO(22, 141, 99, 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                    );
                  },
                  child: const Text(
                    '혹시 비밀번호를 잊어버리셨나요?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(184, 184, 184, 1),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
