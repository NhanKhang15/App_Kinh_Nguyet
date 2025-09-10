import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../login/login_screen.dart';
import 'package:frontend/constants/config.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String phoneNumber = '';
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String result = '';

  Future<void> signup() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse('${AppConfig.baseUrl}/signup');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
      }),
    );

    final data = jsonDecode(response.body);
    setState(() {
      result = data['message'];
      isLoading = false;
    });
    if (data['success'] == true || (result.toLowerCase().contains('thành công'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.isNotEmpty ? result : 'Đăng ký thất bại!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDEFF4),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: AssetImage('assets/images/logo.png'),
                height: 100,
              ),
              Text(
                'FLORIA',
                style: TextStyle(
                  color: Color(0xFFFF33CC),
                  fontSize: 28,
                  fontFamily: 'hideMelody',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Ứng dụng chăm sóc sức khỏe phụ nữ'),
              SizedBox(height: 16),
              Container(
                width: 370,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Đăng Ký',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 8),
                      Text('Tạo tài khoản để bắt đầu hành trình của bạn',
                          style: TextStyle(
                            color: Colors.grey,
                          )),
                      SizedBox(height: 24),

//
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Họ và tên *',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                      SizedBox(height: 24),

                      TextFormField(
                        onChanged: (val) => username = val,
                        validator: (val) =>
                            val!.isEmpty ? 'Không để trống ' : null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_outlined),
                          hintText: 'Nhập họ và tên',
                          filled: true,
                          fillColor: Color(0xFFF1F1F1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

//
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email *',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                      SizedBox(height: 24),

                      TextFormField(
                        onChanged: (val) => email = val,
                        validator: (val) =>
                            val!.contains('@') ? null : 'Email không hợp lệ! ',
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'Nhập đại chỉ Email',
                          filled: true,
                          fillColor: Color(0xFFF1F1F1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

//
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Số điện thoại *',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                      SizedBox(height: 24),

                      TextFormField(
                        onChanged: (val) => phoneNumber = val,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone_outlined),
                          hintText: 'Nhập số điện thoại',
                          filled: true,
                          fillColor: Color(0xFFF1F1F1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

//
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Mật khẩu *',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                      SizedBox(height: 24),

                      TextFormField(
                        onChanged: (val) => password = val,
                        validator: (val) =>
                            val!.length >= 6 ? null : 'Ít nhất 6 ký tự',
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_open_outlined),
                          hintText: 'Nhập mật khẩu',
                          filled: true,
                          fillColor: Color(0xFFF1F1F1),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

//
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Xác nhận mật khẩu *',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                      SizedBox(height: 24),

                      TextFormField(
                        obscureText: _obscureConfirmPassword,
                        onChanged: (val) => confirmPassword = val,
                        validator: (val) =>
                            val == password ? null : 'Mật khẩu không khớp',
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_open_outlined),
                          hintText: 'Nhập lại mật khẩu',
                          filled: true,
                          fillColor: Color(0xFFF1F1F1),
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(_obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      Container(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 14),
                            children: [
                              TextSpan(
                                  text: 'Bằng việc đăng ký, bạn đồng ý với '),
                              TextSpan(
                                text: 'Điều khoản sử dụng ',
                                style: TextStyle(
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                              TextSpan(text: 'và '),
                              TextSpan(
                                text: 'Chính sách bảo mật ',
                                style: TextStyle(
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                              TextSpan(text: 'của chúng tôi. '),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                              colors: [Color(0xFFFF3366), Color(0xFF9F33FF)]),
                        ),
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    signup();
                                  }
                                },
                                child: const Text(
                                  'Đăng Ký',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                      ),

                      SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("Hoặc tiếp tục với"),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: FaIcon(FontAwesomeIcons.google, size: 18),
                              label: Text('Google'),
                              onPressed: () {},
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon:
                                  FaIcon(FontAwesomeIcons.facebookF, size: 18),
                              label: Text('Facebook'),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Đã có tài khoản?'),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Đăng Nhập',
                                style: TextStyle(color: Colors.redAccent),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 32),
                  Column(
                    children: [
                      Text(
                        '© 2025 Floria. Tất cả quyền được bảo lưu.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text('Điều khoản',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('Bảo mật',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('Hỗ trợ',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
