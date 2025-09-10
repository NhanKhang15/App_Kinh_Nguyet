import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/constants/config.dart';
import 'package:frontend/User/screens/widgets/user_account.dart';

class UserAnswerApi {
  UserAnswerApi();

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
      };

Future<String> upsertAnswer({
    required UserAccount userAccount,
    required int questionId,
    required int answerId,
    int? cycleId,
  }) async {
    final int userId = userAccount.id;
    if (userId <= 0) throw Exception('Invalid userId from UserAccount');

    final url = Uri.parse('${AppConfig.baseUrl}/api/user-answers');
    final body = {
      'userId': userId,
      'questionId': questionId,
      'answerId': answerId,
      'cycleId': cycleId,
    };

    // debug
    // ignore: avoid_print
    print('→ PUT $url body=$body');

    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    // ignore: avoid_print
    print('← ${res.statusCode} ${res.body}');

    if (res.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(res.body);
      return (json['status'] as String?) ?? 'ok';
    }

    // Nếu BE trả 400 với "error": ... thì show gọn cho user
    if (res.statusCode == 400) {
      try {
        final Map<String, dynamic> err = jsonDecode(res.body);
        final msg = (err['error'] ?? err['message'] ?? res.body).toString();
        throw Exception('Next failed (400): $msg');
      } catch (_) {
        throw Exception('Next failed (400): ${res.body}');
      }
    }

    throw Exception('Next failed: ${res.statusCode} ${res.body}');
  }
}
