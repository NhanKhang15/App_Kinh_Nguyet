// lib/Admin/list_of_questions/answers/answer_service.dart
import 'answer.dart';
import 'answer_api.dart';

class AnswerService {
  final Map<int, List<Answer>> _cache = {};
  final Map<int, Future<List<Answer>>> _inflight = {};

  Future<List<Answer>> getByQuestionId(int questionId) {
    if (_cache.containsKey(questionId)) return Future.value(_cache[questionId]);
    if (_inflight.containsKey(questionId)) return _inflight[questionId]!;

    final fut = AnswerApi.fetchAnswers(questionId: questionId).then((list) {
      _cache[questionId] = list;
      _inflight.remove(questionId);
      return list;
    }).catchError((e) {
      _inflight.remove(questionId);
      throw e;
    });

    _inflight[questionId] = fut;
    return fut;
  }

  /// clear cache để load lại lần sau
  void invalidate(int questionId) {
    _cache.remove(questionId);
  }

  void put(int questionId, List<Answer> latest) {
    _cache[questionId] = latest;
  }

  Future<List<Answer>> refresh(int questionId) async {
    invalidate(questionId);
    return getByQuestionId(questionId);
  }

  void clear() {
    _cache.clear();
    _inflight.clear();
  }

  Future<Answer> createAnswer({
    required int questionId,
    required String text,
    String? label,
    int? orderInQuestion,
  }) async {
    final answer = await AnswerApi.create(
      questionId: questionId,
      text: text,
      label: label,
      orderInQuestion: orderInQuestion,
    );
    
    // Cập nhật cache
    if (_cache.containsKey(questionId)) {
      _cache[questionId]!.add(answer);
    }
    
    return answer;
  }
}
