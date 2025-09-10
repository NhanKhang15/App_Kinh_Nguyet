// services/question_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/config.dart'; // AppConfig.baseUrl
import 'question.dart';
import '../question_set/QuestionSet.dart';

class QuestionService {
  final List<Question> _all = [];
  Map<int, String> _setIdToName = {};

  List<Question> get all => List.unmodifiable(_all);
  Set<String> get setNames => _all.map((e) => e.setName).toSet();

  Uri _buildUri(String path, Map<String, dynamic> qp) {
    final params = <String, String>{};
    qp.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.isEmpty) return;
      params[k] = v.toString();
    });
    return Uri.parse('${AppConfig.baseUrl}$path')
        .replace(queryParameters: params.isEmpty ? null : params);
  }

  Future<void> _loadQuestionSets() async {
    final url = _buildUri('/api/question-sets', {
      'active': true,
      'page': 0,
      'size': 200, // tuỳ nhu cầu
      'sort': 'updatedAt,desc'
    });
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Load question sets failed: ${res.statusCode}');
    }
    final data = jsonDecode(res.body);
    final List list = (data is Map && data['content'] != null)
        ? data['content']
        : (data as List);
    final sets = list.map((e) => QuestionSet.fromJson(e)).toList();
    _setIdToName = {
      for (final s in sets) s.id: s.name,
    };
  }

  Future<void> updateStatus({
    required int id,
    required bool active,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/questions/$id/status?active=$active');

    // GỌI THẲNG PATCH, không header để hạn chế preflight rườm rà
    final res = await http.patch(uri).timeout(const Duration(seconds: 10));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

/// Gọi API PATCH /api/questions/{id} với body {"text": "..."} sửa câu hỏi
  Future<void> patchQuestionText({
    required int id,
    required String text,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/questions/$id');
    final res = await http
        .patch(
          uri,
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'text': text}),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }

// xóa câu hỏi và answers, đồng thời reset thứ tự
  Future<void> deleteQuestionApi({required int id}) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/questions/$id');
      
      // Gọi API xóa (backend sẽ handle việc xóa answers và reset thứ tự)
      final res = await http.delete(url);
      
      if (res.statusCode != 204) {
        throw Exception('Lỗi khi xóa câu hỏi: ${res.statusCode}');
      }

    } catch (e) {
      throw Exception('Lỗi trong quá trình xóa: $e');
    }
  }

  Future<void> patchQuestionOrder(int id, int newOrder) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/questions/$id');
    final res = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderInSet': newOrder}),
    );
    if (res.statusCode >= 400) {
      throw Exception('PATCH order failed: ${res.statusCode} - ${res.body}');
    }
  }

  Future<void> moveTo({
    required int id,
    required int targetIndex, // 1-based
    int? targetSetId,         // null = giữ nguyên bộ
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/questions/$id/move-to');
    final body = {
      'targetIndex': targetIndex,
      if (targetSetId != null) 'targetSetId': targetSetId,
    };
    final res = await http.patch(
      uri,
      headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }


  Future<Question> createQuestion({
    required String questionText,
    required int questionSetId,
    required String typeId,          // "single" | "multiple" | "text"
    int? orderInSet,                 // optional
    bool? isActive,                  // optional (default true ở backend)
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/questions');

    final body = <String, dynamic>{
      'questionText': questionText.trim(),
      'questionSetId': questionSetId,
      'typeId': typeId,             // map từ UI
      if (orderInSet != null) 'orderInSet': orderInSet,
      if (isActive != null) 'isActive': isActive,
    };

    final res = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final q = Question.fromJson(json, setNameOf: (sid) => 'Set #$sid'); // hoặc map tên set của bạn
      // optional: thêm ngay vào cache local để UI thấy liền
      _all.add(q);
      return q;
    } else {
      // bắn ra thông tin lỗi để UI hiện SnackBar/Dialog
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
  }


  /// Gọi API lấy list câu hỏi (server-side filtering/pagination nếu cần)
  Future<void> loadQuestions(
      {String? q,
      int? setId,
      bool? active,
      int page = 0,
      int size = 50}) async {
    // 1) Đảm bảo có map setId->name để hiển thị
    if (_setIdToName.isEmpty) {
      await _loadQuestionSets();
    }

    // 2) Lấy câu hỏi
    final url = _buildUri('/api/questions', {
      'q': q,
      'setId': setId,
      'active': active,
      'page': page,
      'size': size,
      'sort': 'questionSetId,asc',
      'sort2': 'orderInSet,asc', // nếu backend hỗ trợ nhiều sort params
    });

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Load questions failed: ${res.statusCode}');
    }

    final data = jsonDecode(res.body);
    final List arr = (data is Map && data['content'] != null)
        ? data['content']
        : (data as List);

    _all
      ..clear()
      ..addAll(arr.map((e) => Question.fromJson(e,
          setNameOf: (sid) => _setIdToName[sid] ?? 'Set #$sid')));
  }

  // ========= Các thao tác cũ vẫn giữ, sau này bạn nối API PATCH/DELETE =========
  void updateText(int id, String newText) {
    final q = _all.firstWhere((e) => e.id == id);
    q.text = newText;
  }

  void updateOrder(int id, int newOrder) {
    final q = _all.firstWhere((e) => e.id == id);
    q.order = newOrder;
  }

  void toggleActive(int id) {
    final q = _all.firstWhere((e) => e.id == id);
    q.isActive = !q.isActive;
  }

  void restoreAt(int index, Question q) {
    // clone ra list mới từ _all rồi insert lại
    _all.insert(index < 0 || index > _all.length ? _all.length : index, q);
  }

  void deleteById(int id) {
    _all.removeWhere((e) => e.id == id);
  }

  void setActive(int id, bool active) {
    final i = _all.indexWhere((e) => e.id == id);
    if (i != -1) {
      _all[i] = _all[i].copy(isActive: active); // cần có copyWith trong model
    }
  }

  // Helper filter (nếu vẫn muốn lọc ở client trên data đã tải)
  List<Question> filter({required String keyword, String? setName}) {
    final kw = keyword.trim().toLowerCase();
    final list = _all.where((q) {
      final okText = q.text.toLowerCase().contains(kw);
      final okSet = setName == null || setName.isEmpty || q.setName == setName;
      return okText && okSet;
    }).toList();
    list.sort((a, b) {
      final bySet = a.setName.compareTo(b.setName);
      return bySet != 0 ? bySet : a.order.compareTo(b.order);
    });
    return list;
  }
}
