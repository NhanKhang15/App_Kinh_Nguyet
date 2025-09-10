import 'package:flutter/material.dart';
import '../questions/question.dart';
import '../widgets/Reorderable_Set_List.dart';
import '../widgets/question_more_sheet.dart';

class QuestionListGrouped extends StatelessWidget {
  final List<Question> questions;
  final void Function(String setName) onAddInSet;
  final void Function(Question) onEditText;
  final Future<void> Function(Question) onDelete;
  final void Function(Question) onToggleActive;

  /// NEW: callback mở editor đáp án
  final Future<void> Function(Question) onEditAnswers;

  /// NEW: map key để ép AnswerList rebuild theo questionId
  final Map<int, Key> answersKeys;

  const QuestionListGrouped({
    super.key,
    required this.questions,
    required this.onAddInSet,
    required this.onEditText,
    required this.onDelete,
    required this.onToggleActive,
    required this.onEditAnswers,
    required this.answersKeys,
  });

  @override
  Widget build(BuildContext context) {
    // group theo setName
    final Map<String, List<Question>> grouped = {};
    for (final q in questions) {
      grouped.putIfAbsent(q.setName, () => []).add(q);
    }
    final sections = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        for (final e in sections)
          ReorderableSetList(
            setName: e.key,
            items: (e.value..sort((a, b) => a.order.compareTo(b.order))),
            onAddInSet: onAddInSet,
            onEditText: onEditText,
            onDelete: onDelete,
            onToggleActive: onToggleActive,
            showMoreSheet: (q) {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => QuestionMoreSheet(
                  onEdit: () => onEditText(q),
                  onEditPoint: () {/* nếu có dùng sau bổ sung */},
                  onDelete: onDelete,
                  onEditAnswers: onEditAnswers,   
                  question: q,
                ),
              );
            },
            answersKeys: answersKeys,           
          ),
      ],
    );
  }
}
