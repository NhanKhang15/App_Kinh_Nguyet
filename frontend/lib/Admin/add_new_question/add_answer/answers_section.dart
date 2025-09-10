import 'package:flutter/material.dart';
import '../add_queestion/add_question_actions.dart';
import '../widgets/PastelSectionCard.dart';
import 'select_answer.dart';
import '../pages/branch_answer.dart';

class AnswersSection extends StatelessWidget {
  final AddQuestionActions ctrl;
  const AnswersSection({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return PastelSectionCard(
      title: '2  Đáp án',
      leading: _circleIndex('2'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ctrl.isTextType)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Loại "Nhập đáp án tự do" — không cần danh sách đáp án.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            )
          else ...[
            ...List.generate(ctrl.answers.length, (i) {
              final a = ctrl.answers[i];
              return SelectAnswer(
                label: a.label ?? String.fromCharCode(65 + i), // A, B, C... nếu không có label
                text: a.text,
                onRemove: () => ctrl.removeAnswer(i),
                onTextChanged: (v) => ctrl.updateAnswer(i, text: v),
              );
            }),
            OutlinedButton.icon(
              onPressed: ctrl.addAnswer,
              icon: const Icon(Icons.add),
              label: const Text('Thêm đáp án'),
            ),
          ],
          const SizedBox(height: 6),
          if (ctrl.showCombination) ...[
            const Divider(height: 20),
            const Text('🔀 Rẽ nhánh theo tổ hợp',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...List.generate(ctrl.rules.length, (i) {
              final r = ctrl.rules[i];
              return BranchAnswer(
                combination: r['combination'] ?? '',
                nextSetId: r['next'],
                sets: ctrl.sets,
                onCombinationChanged: (v) => ctrl.updateRule(i, combination: v),
                onNextChanged: (v) => ctrl.updateRule(i, next: v),
                onRemove: () => ctrl.removeRule(i),
              );
            }),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: ctrl.addRule,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm tổ hợp'),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Ví dụ: tổ hợp "A,B" sẽ dẫn tới bộ tiếp theo.',
                      style: TextStyle(color: Colors.black54)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _circleIndex(String n) => Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: Color(0xFFEDEAFF)),
        alignment: Alignment.center,
        child: Text(n, style: const TextStyle(fontWeight: FontWeight.w700)),
      );
}
