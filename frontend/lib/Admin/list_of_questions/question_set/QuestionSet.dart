class QuestionSet {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  QuestionSet({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory QuestionSet.fromJson(Map<String, dynamic> json) {
    return QuestionSet(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }
}
  