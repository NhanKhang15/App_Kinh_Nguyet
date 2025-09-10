// models/question.dart
class Question {
  final int id;
  String text;
  final int setId; // question_set_id từ DB
  String setName; // map từ setId -> tên bộ (để UI cũ chạy)
  int order; // order_in_set
  bool isActive;
  final String? type; // 'single' | 'multiple' | 'text' (nếu cần)

  Question({
    required this.id,
    required this.text,
    required this.setId,
    required this.setName,
    required this.order,
    required this.isActive,
    this.type,
  });

  Question copy({
    int? id,
    String? text,
    int? setId,
    String? setName,
    int? order,
    bool? isActive,
    String? type,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      setId: setId ?? this.setId,
      setName: setName ?? this.setName,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
    );
  }

  // Nếu bạn đã có map setId->name thì truyền vào để dựng setName
  factory Question.fromJson(Map<String, dynamic> j,
      {String Function(int)? setNameOf}) {
    final setId = j['questionSetId'] ?? j['question_set_id'];
    final name = (setNameOf != null) ? setNameOf(setId) : 'Set #$setId';
    return Question(
      id: j['id'] as int,
      text: j['questionText'] ?? j['text'],
      setId: setId as int,
      setName: name,
      order: j['orderInSet'] ?? j['order_in_set'] as int,
      isActive: (j['isActive'] ?? j['is_active'] ?? true) as bool,
      type: j['type'] as String?,
    );
  }
}
