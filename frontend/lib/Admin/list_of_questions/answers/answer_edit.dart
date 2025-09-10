class AnswerEdit {
  int? id;
  String text;
  bool correct;
  String? imageUrl;

  AnswerEdit(
      {this.id, required this.text, this.correct = false, this.imageUrl});

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'correct': correct,
        'imageUrl': imageUrl,
      };
}

class EditQuestionResult {
  final String questionText;
  final List<AnswerEdit> answers;

  EditQuestionResult({required this.questionText, required this.answers});
}
