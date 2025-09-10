import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/User/screens/auth/login/login_screen.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Không logout
            child: const Text("Huỷ"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Đồng ý logout
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 10),
      child: TextButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout, color: Colors.grey),
        label: const Row(
          children: [
            Text("Đăng xuất"),
          ],
        ),
      ),
    );
  }
}