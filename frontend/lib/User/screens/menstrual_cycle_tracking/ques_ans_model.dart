class Answer {
  final int id;
  final String text;
  Answer({required this.id, required this.text});

  factory Answer.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['answerId'] ?? json['answer_id'];
    final id = (rawId is int) ? rawId : int.tryParse('$rawId') ?? 0;

    final rawText = json['answerText'] ?? json['text'] ?? json['label'] ?? '';
    return Answer(id: id, text: rawText.toString().trim());
  }
}

class Question {
  final int id;              
  final String text;         
  final int ordinal;         
  final List<Answer> answers;

  Question({
    required this.id,
    required this.text,
    required this.ordinal,
    required this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = (rawId is int) ? rawId : int.tryParse('$rawId') ?? 0;

    final rawText = json['questionText'] ?? json['text'] ?? '';
    final ordRaw = json['ordinal'] ?? json['orderInSet'] ?? json['order'] ?? json['index'];
    final ordinal = (ordRaw is int) ? ordRaw : int.tryParse('$ordRaw') ?? 0;

    final answersJson = (json['answers'] as List?) ?? const [];
    final answers = answersJson
        .map((e) => Answer.fromJson(e as Map<String, dynamic>))
        .toList();

    return Question(
      id: id,
      text: rawText.toString().trim().isEmpty ? 'Chưa có câu hỏi' : rawText.toString().trim(),
      ordinal: ordinal,
      answers: answers,
    );
  }
}

/// Kết quả khi gọi theo ordinal: có meta để hiển thị progress.
class OrdinalQuestionResult {
  final int setId;
  final int ordinal; // 1-based
  final int total;
  final Question question;

  OrdinalQuestionResult({
    required this.setId,
    required this.ordinal,
    required this.total,
    required this.question,
  });
}
