class Answer {
  final int id;
  final String text;
  final String? label;
  final int orderInQuestion;

  Answer({required this.id, required this.text, this.label, required this.orderInQuestion});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      text: json['text'] ?? '',
      label: json['label'],
      orderInQuestion: json['orderInQuestion'] ?? 0,
    );
  }
}
