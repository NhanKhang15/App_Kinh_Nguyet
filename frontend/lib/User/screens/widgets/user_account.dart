// widgets/user_account.dart
class UserAccount {
  final int id;
  final String username;
  final String email;
  final String role;

  UserAccount({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: (json['user_id'] ?? 0) as int,
      username: (json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      role: (json['role'] ?? 'user') as String,
    );
  }
}
