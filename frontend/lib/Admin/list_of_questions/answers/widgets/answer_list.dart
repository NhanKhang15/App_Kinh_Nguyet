// lib/Admin/list_of_questions/answers/widgets/answer_list.dart
import 'package:flutter/material.dart';
import '../answer.dart';
import '../answer_service.dart';

class AnswerList extends StatefulWidget {
  final int questionId;
  final AnswerService service;
  const AnswerList(
      {super.key, required this.questionId, required this.service});

  @override
  State<AnswerList> createState() => _AnswerListState();
}

class _AnswerListState extends State<AnswerList> {
  late Future<List<Answer>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.getByQuestionId(widget.questionId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Answer>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: const [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Đang tải câu trả lời...'),
              ],
            ),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text('Lỗi tải câu trả lời: ${snap.error}',
                style: const TextStyle(color: Colors.red)),
          );
        }
        final answers = snap.data ?? const <Answer>[];
        if (answers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text('— Chưa có câu trả lời —',
                style: TextStyle(color: Colors.black54)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lựa chọn trả lời',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            ...answers.map((a) {
              final icon = Icons.circle;
              final color = Colors.grey;
              final prefix = a.label != null ? '${a.label}. ' : '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$prefix${a.text}',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
