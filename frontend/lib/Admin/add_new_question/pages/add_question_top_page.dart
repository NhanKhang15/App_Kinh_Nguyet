// lib/Admin/add_queestion/add_question_top_page.dart
import 'package:flutter/material.dart';
import '../add_queestion/add_question_actions.dart';
import '../pages/question_info_section.dart';
import '../add_answer/answers_section.dart';

class AddQuestionTopPage extends StatelessWidget {
  final AddQuestionActions ctrl;
  
  const AddQuestionTopPage({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            color: const Color(0xFFFDEFF4),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                physics: ctrl.saving
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // header
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bộ Câu Hỏi về Kinh Nguyệt',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800)),
                          SizedBox(height: 6),
                          Text('Tạo câu hỏi mới cho hệ thống',
                              style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Section 1: Thông tin câu hỏi
                    QuestionInfoSection(ctrl: ctrl),

                    const SizedBox(height: 14),

                    // Section 2: Đáp án (+ Rẽ nhánh) — nếu loại "text" thì ẩn
                    if (ctrl.typeIndex != 2) AnswersSection(ctrl: ctrl),

                    const SizedBox(height: 20),

                    // Save button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: ctrl.saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_outlined),
                          label: const Text('Lưu câu hỏi'),
                          onPressed: ctrl.saving
                              ? null
                              : () async {
                                  try {
                                                                        final question = await ctrl.save(context);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Đã lưu câu hỏi: ${question.text}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                      
                                      // Reset form
                                      ctrl.questionTextCtrl.clear();
                                      ctrl.setSetId(null);
                                      ctrl.changeType(0);
                                    }
                                    // TODO: reset form nếu cần:
                                    // ctrl.questionTextCtrl.clear();
                                    // ctrl.setSetId(null);
                                    // ctrl.changeType(0);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.toString())),
                                      );
                                    }
                                  }
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
