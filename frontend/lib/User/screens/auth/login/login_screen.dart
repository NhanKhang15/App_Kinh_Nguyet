import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../signup/signup_screen.dart';
import '../../homepage/HomePage.dart';
import '../../widgets/user_account.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/constants/config.dart';
import '../../../../Admin/homepage/AminHomePage.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final resp = await http.post(
        Uri.parse('${AppConfig.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _userController.text.trim(), 
          'password': _passController.text,
        }),
      );

      // HTTP lỗi
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi máy chủ (${resp.statusCode})')),
        );
        return;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final success = data['success'] == true;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Sai tài khoản hoặc mật khẩu')),
        );
        return;
      }

      // Parse user
      final user = UserAccount.fromJson(data);

      // Điều hướng theo role
      if (user.role.toLowerCase() == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHomePage(userAccount: user)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(userAccount: user)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDEFF4),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 48),
              const Image(image: AssetImage('assets/images/logo.png'), height: 100),
              const Text(
                'FLORIA',
                style: TextStyle(
                  color: Color(0xFFFF33CC),
                  fontSize: 28,
                  fontFamily: 'hideMelody',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('Ứng dụng chăm sóc sức khỏe phụ nữ'),
              const SizedBox(height: 16),

              Container(
                width: 370,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Đăng Nhập',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Chào mừng bạn quay trở lại!',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('Email hoặc Tên đăng nhập *',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _userController,
                        autofillHints: const [AutofillHints.username, AutofillHints.email],
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Không được để trống' : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: 'Nhập email hoặc username',
                          filled: true,
                          fillColor: const Color(0xFFF1F1F1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('Mật Khẩu *',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passController,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Không được để trống' : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_open_outlined),
                          hintText: 'Nhập mật khẩu',
                          filled: true,
                          fillColor: const Color(0xFFF1F1F1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(() {
                              _obscurePassword = !_obscurePassword;
                            }),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {}, // TODO: forgot password flow
                          child: const Text('Quên Mật Khẩu?',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      ),

                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ).merge(ButtonStyle(
                            // để gradient ở Container bọc ngoài
                            foregroundColor: WidgetStateProperty.resolveWith(
                                (s) => Colors.white),
                          )),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF3366), Color(0xFF9F33FF)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Đăng Nhập',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("Hoặc tiếp tục với"),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const FaIcon(FontAwesomeIcons.google, size: 18),
                              label: const Text('Google'),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const FaIcon(FontAwesomeIcons.facebookF, size: 18),
                              label: const Text('Facebook'),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Chưa có tài khoản'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignupScreen()),
                              );
                            },
                            child: const Text('Đăng ký ngay',
                                style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Column(
                children: [
                  const Text('© 2025 Floria. Tất cả quyền được bảo lưu.',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Điều khoản')),
                      TextButton(onPressed: () {}, child: const Text('Bảo mật')),
                      TextButton(onPressed: () {}, child: const Text('Hỗ trợ')),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}