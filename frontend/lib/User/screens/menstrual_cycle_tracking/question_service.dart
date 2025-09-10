import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ques_ans_model.dart';

class QuestionService {
  final String baseUrl;
  const QuestionService({required this.baseUrl});

  /// Lấy câu hỏi thứ [ordinal] (1-based) trong bộ [setId], mặc định lọc active=true.
  /// Backend trả: { setId, ordinal, total, question: {...} }
  /// Service tự fetch thêm answers và gộp vào Question (kèm ordinal).
  Future<OrdinalQuestionResult> getByOrdinal({
    required int setId,
    required int ordinal,
    bool active = true,
  }) async {
    // 1) Meta + question thô (chưa có answers)
    final metaUri = Uri.parse('$baseUrl/api/questions/$setId/$ordinal')
        .replace(queryParameters: {'active': active.toString()});

    final metaRes = await http.get(metaUri).timeout(const Duration(seconds: 10));
    if (metaRes.statusCode != 200) {
      throw Exception('HTTP ${metaRes.statusCode}: ${metaRes.body}');
    }

    final metaJson = jsonDecode(metaRes.body) as Map<String, dynamic>;
    final qMap = metaJson['question'] as Map<String, dynamic>?;
    if (qMap == null) {
      throw Exception('Response missing "question" field');
    }

    // 2) Lấy answers theo questionId (page)
    final qId = qMap['id'];
    final questionId = (qId is int) ? qId : int.tryParse('$qId') ?? 0;

    final ansUri = Uri.parse('$baseUrl/api/answers').replace(queryParameters: {
      'questionId': '$questionId',
      'size': '50',
      'sort': 'orderInQuestion,asc',
    });

    final ansRes = await http.get(ansUri).timeout(const Duration(seconds: 10));
    if (ansRes.statusCode != 200) {
      throw Exception('HTTP ${ansRes.statusCode}: ${ansRes.body}');
    }
    final ansJson = jsonDecode(ansRes.body) as Map<String, dynamic>;
    final answersList = (ansJson['content'] as List?) ?? const [];

    // 3) Gộp để parse về Question đầy đủ — **nhét ordinal vào đây**
    final merged = <String, dynamic>{
      'id': questionId,
      'questionText': qMap['questionText'] ?? qMap['text'],
      'ordinal': metaJson['ordinal'] ?? ordinal, // ✅ ordinal chuẩn, KHÔNG dùng id
      'answers': answersList,
    };
    final question = Question.fromJson(merged);

    final rawSetId = metaJson['setId'];
    final rawOrdinal = metaJson['ordinal'];
    final rawTotal = metaJson['total'];

    return OrdinalQuestionResult(
      setId: (rawSetId is int) ? rawSetId : int.tryParse('$rawSetId') ?? setId,
      ordinal: (rawOrdinal is int) ? rawOrdinal : int.tryParse('$rawOrdinal') ?? ordinal,
      total: (rawTotal is int) ? rawTotal : int.tryParse('$rawTotal') ?? 0,
      question: question,
    );
  }

  /// Nếu vẫn cần lấy 1 câu hỏi theo id (admin/detail), để đây dùng khi cần.
  /// Không có meta ordinal → gán từ `orderInSet` nếu có, hoặc 0.
  Future<Question> getQuestionDetailAndAnswers(int id) async {
    final qUrl = Uri.parse('$baseUrl/api/admin/questions/$id');
    final qRes = await http.get(qUrl).timeout(const Duration(seconds: 10));
    if (qRes.statusCode != 200) {
      throw Exception('HTTP ${qRes.statusCode}: ${qRes.body}');
    }
    final qJson = jsonDecode(qRes.body) as Map<String, dynamic>;

    final aUrl = Uri.parse('$baseUrl/api/answers').replace(queryParameters: {
      'questionId': '$id',
      'size': '50',
      'sort': 'orderInQuestion,asc',
    });
    final aRes = await http.get(aUrl).timeout(const Duration(seconds: 10));
    if (aRes.statusCode != 200) {
      throw Exception('HTTP ${aRes.statusCode}: ${aRes.body}');
    }
    final aJson = jsonDecode(aRes.body) as Map<String, dynamic>;
    final answersList = (aJson['content'] as List?) ?? const [];

    final merged = {
      'id': qJson['id'],
      'questionText': qJson['questionText'] ?? qJson['text'],
      'ordinal': qJson['orderInSet'] ?? qJson['ordinal'] ?? 0, // ✅ best-effort
      'answers': answersList,
    };
    return Question.fromJson(merged);
  }

  /// Lấy chi tiết 1 answer (tuỳ nhu cầu)
  Future<Answer> getAnswer(int id) async {
    final url = Uri.parse('$baseUrl/api/answers/$id');
    final res = await http.get(url).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return Answer.fromJson(data);
  }
}