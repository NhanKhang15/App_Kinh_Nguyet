import 'package:flutter/material.dart';
import '../../list_of_questions/question_set/QuestionSet.dart';

class BranchAnswer extends StatelessWidget {
  final String combination;
  final String? nextSetId;
  final List<QuestionSet> sets;
  final ValueChanged<String> onCombinationChanged;
  final ValueChanged<String?> onNextChanged;
  final VoidCallback onRemove;

  const BranchAnswer({
    required this.combination,
    required this.nextSetId,
    required this.sets,
    required this.onCombinationChanged,
    required this.onNextChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
        border:
            const Border(left: BorderSide(color: Color(0xFF8B95FF), width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: combination,
              onChanged: onCombinationChanged,
              decoration: const InputDecoration(
                hintText: 'Tổ hợp (ví dụ: A,B)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String?>(
              value: nextSetId,
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('-- Bộ tiếp theo --')),
                ...sets.map((s) => DropdownMenuItem(
                    value: s.id.toString(), child: Text(s.name))),
              ],
              onChanged: onNextChanged,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), isDense: true),
            ),
          ),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}
