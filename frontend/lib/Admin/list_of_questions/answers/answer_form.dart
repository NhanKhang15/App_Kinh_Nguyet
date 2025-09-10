import '../answers/answer.dart';

class AnswerForm {
  int? id;              // null = mới
  String text;
  String? label;

  AnswerForm({this.id, required this.text, this.label});

  factory AnswerForm.fromAnswer(Answer a) =>
      AnswerForm(id: a.id, text: a.text, label: a.label);
}
