import 'package:flutter/material.dart';
import '../add_queestion/add_question_actions.dart';
import '../widgets/PastelSectionCard.dart';

class QuestionInfoSection extends StatelessWidget {
  final AddQuestionActions ctrl;
  const QuestionInfoSection({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return PastelSectionCard(
      title: '1  Thông tin câu hỏi',
      leading: _circleIndex('1'),
      child: Column(
        children: [
          // hướng dẫn
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFD3FF)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hướng dẫn:\n'
                    '• Điền đầy đủ trường bắt buộc\n'
                    '• Loại "Nhập đáp án tự do" không cần danh sách đáp án\n'
                    '• Loại "Chọn nhiều đáp án" có thể thêm rẽ nhánh theo tổ hợp',
                    style: TextStyle(height: 1.35),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: ctrl.selectedSetId,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('-- Không chọn --')),
                    ...ctrl.sets.map(
                      (s) => DropdownMenuItem(
                          value: s.id.toString(), 
                          child: Text(s.name)),
                    ),
                  ],
                  onChanged: ctrl.setSetId,
                  decoration: const InputDecoration(
                    labelText: '📁 Bộ câu hỏi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: ctrl.typeIndex,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Chọn 1 đáp án')),
                    DropdownMenuItem(
                        value: 1, child: Text('Chọn nhiều đáp án')),
                    DropdownMenuItem(
                        value: 2, child: Text('Nhập đáp án tự do')),
                  ],
                  onChanged: (v) => ctrl.changeType(v ?? ctrl.typeIndex),
                  decoration: const InputDecoration(
                    labelText: '🔘 Loại câu hỏi',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl.questionTextCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '❓ Nội dung câu hỏi',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
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
