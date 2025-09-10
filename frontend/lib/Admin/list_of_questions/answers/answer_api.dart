import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/config.dart';
import 'answer.dart';
import '../answers/answer_form.dart';

class AnswerApi {
  static Future<List<Answer>> fetchAnswers({
    required int questionId,
    int page = 0,
    int size = 50,
  }) async {
    final url = Uri.parse(
      '${AppConfig.baseUrl}/api/answers'
      '?questionId=$questionId&page=$page&size=$size&sort=orderInQuestion,asc',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Load answers failed (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    final List arr = (data is Map && data['content'] != null)
        ? data['content']
        : (data as List);
    return arr.map((e) => Answer.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Answer> create({
    required int questionId,
    required String text,
    String? label,
    int? orderInQuestion,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/answers');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'questionId': questionId,
        'text': text,
        'label': label,
        'orderInQuestion': orderInQuestion,
      }),
    );
    if (res.statusCode != 201) {
      throw Exception('Create answer failed: ${res.statusCode} - ${res.body}');
    }
    return Answer.fromJson(jsonDecode(res.body));
  }

  static Future<Answer> patch({
    required int id,
    String? text,
    String? label,
    int? orderInQuestion,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/answers/$id');
    final res = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (text != null) 'text': text,
        if (label != null) 'label': label,
        if (orderInQuestion != null) 'orderInQuestion': orderInQuestion,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Patch answer failed: ${res.statusCode} - ${res.body}');
    }
    return Answer.fromJson(jsonDecode(res.body));
  }

  static Future<void> delete(int id) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/answers/$id');
    final res = await http.delete(url);
    if (res.statusCode != 204) {
      throw Exception('Delete answer failed: ${res.statusCode} - ${res.body}');
    }
  }

  /// PATCH /api/answers/reorder  [{id, orderInQuestion}]
  static Future<void> reorder(List<Map<String, dynamic>> items) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/answers/reorder');
    final res = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(items),
    );
    if (res.statusCode != 200) {
      throw Exception('Reorder failed: ${res.statusCode} - ${res.body}');
    }
  }

  /// Upsert theo diff giữa danh sách cũ và mới (tạo/sửa/xoá + reorder)
  static Future<void> upsertAnswers({
    required int questionId,
    required List<Answer> original,          // từ server
    required List<AnswerForm> edited,        // từ UI
  }) async {
    // Map cũ theo id
    final oldById = {for (final a in original) a.id: a};

    // 1) create / patch
    int runningOrder = 1;
    final toReorder = <Map<String, dynamic>>[];
    final keepIds = <int>{};

    for (final e in edited) {
      if (e.id == null) {
        final created = await create(
          questionId: questionId,
          text: e.text,
          label: e.label?.isEmpty == true ? null : e.label,
          orderInQuestion: runningOrder,
        );
        keepIds.add(created.id);
      } else {
        // nếu có thay đổi, patch
        final old = oldById[e.id]!;
        final needPatch = (e.text != old.text) ||
            ((e.label ?? '') != (old.label ?? '')) ||
            (old.orderInQuestion != runningOrder);
        if (needPatch) {
          await patch(
            id: e.id!,
            text: e.text != old.text ? e.text : null,
            label: (e.label ?? '') != (old.label ?? '') ? e.label : null,
            orderInQuestion: old.orderInQuestion == runningOrder ? null : runningOrder,
          );
        }
        keepIds.add(e.id!);
      }
      // gom reorder payload (optional – phòng backend cần bulk)
      if (e.id != null) {
        toReorder.add({'id': e.id, 'orderInQuestion': runningOrder});
      }
      runningOrder++;
    }

    // 2) delete cái bị bỏ
    for (final a in original) {
      if (!keepIds.contains(a.id)) {
        await delete(a.id);
      }
    }

    // 3) bulk reorder (nếu cần tối ưu)
    if (toReorder.isNotEmpty) {
      await reorder(toReorder);
    }
  }
}
