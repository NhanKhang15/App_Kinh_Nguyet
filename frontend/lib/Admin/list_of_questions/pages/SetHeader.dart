import 'package:flutter/material.dart';
import 'package:frontend/Admin/add_new_question/add_question_pages.dart';
import '../question_set/set_styles.dart';


class SetHeader extends StatelessWidget {
  final String setName;
  final SetStyle style;
  final int total;
  final VoidCallback onAdd;

  const SetHeader({
    required this.setName,
    required this.style,
    required this.total,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
              children: [
                TextSpan(text: '$total câu hỏi', style: const TextStyle(fontWeight: FontWeight.w700)),
                const TextSpan(text: '  '),
                TextSpan(
                  text: '(${style.label})',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddQuestionPage()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Thêm câu hỏi'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED), // tím giống hình
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
