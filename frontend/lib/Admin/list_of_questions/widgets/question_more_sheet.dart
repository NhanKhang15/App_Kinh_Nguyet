import 'package:flutter/material.dart';
import '../questions/question.dart';

class QuestionMoreSheet extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onEditPoint;
  final Future<void> Function(Question q) onDelete;
  final Future<void> Function(Question q) onEditAnswers;
  final Question question;

  const QuestionMoreSheet({
    super.key,
    required this.onEdit,
    required this.onEditPoint,
    required this.onDelete,
    required this.onEditAnswers,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final itemStyle = Theme.of(context).textTheme.titleMedium;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note_outlined),
              title: Text('Chỉnh sửa question', style: itemStyle),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: Text('Sửa đáp án', style: itemStyle),
              onTap: () async {
                Navigator.pop(context);
                await onEditAnswers(question); 
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: Text('Đổi điểm', style: itemStyle),
              onTap: () {
                Navigator.pop(context);
                onEditPoint();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Xoá question',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await onDelete(question);
              },
            ),
          ],
        ),
      ),
    );
  }
}
