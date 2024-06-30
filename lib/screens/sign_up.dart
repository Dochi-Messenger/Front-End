import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dochi2/screens/sign_in.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  XFile? _pickedFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _militaryIdController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final String serverIp = 'http://172.20.10.2:5001';

  Future<void> _submit() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    String? base64Image;
    if (_pickedFile != null) {
      final bytes = await _pickedFile!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    final response = await http.post(
      Uri.parse('$serverIp/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'username': _usernameController.text,
        'password': _passwordController.text,
        'name': _nameController.text,
        'military_id': _militaryIdController.text,
        'unit': _unitController.text,
        'm_rank': _rankController.text,
        'phone': _phoneNumberController.text,
        'profile_img': base64Image,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 성공')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SigninPage()),
      );
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['error'] ?? 'Unknown error')),
      );
    }
  }

  Widget _buildProfileImage(double imageSize) {
    return _pickedFile == null
        ? Container(
      constraints: BoxConstraints(
        minHeight: imageSize,
        minWidth: imageSize,
      ),
      child: GestureDetector(
        onTap: _showBottomSheet,
        child: Center(
          child: Image.asset(
            'assets/images/account.png',
            width: 120,
            height: 120,
          ),
        ),
      ),
    )
        : Center(
      child: Stack(
        children: [
          Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: Theme.of(context).colorScheme.primary),
              image: DecorationImage(
                image: FileImage(File(_pickedFile!.path)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
              onPressed: _showBottomSheet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hintText, Color? labelColor, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color.fromRGBO(175, 175, 175, 1),
            ),
          ),
          SizedBox(
            height: 50,
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: hintText,
                border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: Colors.black)),
                contentPadding: const EdgeInsets.only(left: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCameraImage,
              child: const Text('사진찍기'),
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 3),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getPhotoLibraryImage,
              child: const Text('라이브러리에서 불러오기'),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Future<void> _getCameraImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    _processPickedImage(pickedFile);
  }

  Future<void> _getPhotoLibraryImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    _processPickedImage(pickedFile);
  }

  void _processPickedImage(XFile? pickedFile) {
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    } else {
      print('이미지 선택 안 함');
    }
  }

  @override
  Widget build(BuildContext context) {
    final _imageSize = MediaQuery.of(context).size.width / 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileImage(_imageSize),
            const SizedBox(height: 20),
            _buildTextField("이름", _nameController, hintText: "이름을 입력해주세요", labelColor: Colors.blueGrey),
            const SizedBox(height: 10),
            _buildTextField("아이디", _usernameController, hintText: "아이디를 입력해주세요", labelColor: Colors.blueGrey),
            const SizedBox(height: 10),
            _buildTextField("군번", _militaryIdController, hintText: "군번을 입력해주세요", labelColor: Colors.blueGrey),
            const SizedBox(height: 10),
            _buildTextField("비밀번호", _passwordController, hintText: "비밀번호를 입력해주세요", labelColor: Colors.blueGrey, obscureText: true),
            const SizedBox(height: 10),
            _buildTextField("비밀번호 재확인", _confirmPasswordController, hintText: "비밀번호를 입력해주세요", labelColor: Colors.blueGrey, obscureText: true),
            const SizedBox(height: 10),
            _buildTextField("소속부대", _unitController, hintText: "소속부대를 입력해주세요", labelColor: Colors.blueGrey),
            const SizedBox(height: 10),
            _buildTextField("계급", _rankController, hintText: "계급을 입력해주세요", labelColor: Colors.blueGrey),
            const SizedBox(height: 10),
            _buildTextField("전화번호", _phoneNumberController, hintText: "전화번호를 입력해주세요", labelColor: Colors.blueGrey),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 120),
                backgroundColor: const Color.fromRGBO(22, 141, 99, 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                '완료',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _militaryIdController.dispose();
    _unitController.dispose();
    _rankController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
