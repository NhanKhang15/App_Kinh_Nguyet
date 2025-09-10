import 'dart:convert';
import 'package:frontend/constants/config.dart';
import 'package:frontend/Admin/list_of_questions/question_set/QuestionSet.dart';
import 'package:http/http.dart' as http;

Future<List<QuestionSet>> fetchQuestionSets() async {
  final url = Uri.parse('${AppConfig.baseUrl}/api/question-sets');
  final res = await http.get(url);
  if (res.statusCode != 200) {
    throw Exception('Failed to load question sets: ${res.statusCode}');
  }

  final data = jsonDecode(res.body);
  // Nếu backend trả kiểu Page {content: [...]} của Spring
  final List arr = (data is Map && data['content'] != null) ? data['content'] : (data as List);
  return arr.map((e) => QuestionSet.fromJson(e)).toList();
}
