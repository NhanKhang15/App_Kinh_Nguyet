import 'package:flutter/material.dart';
import 'answer.dart';
import 'answer_form.dart';
import 'answer_api.dart';
import 'answer_service.dart';


class AnswerEditorDialog {
  /// Trả về danh sách đáp án mới sau khi lưu (null nếu huỷ / lỗi)
  static Future<List<Answer>?> open(
    BuildContext context, {
    required int questionId,
    required AnswerService service,
  }) async {
    // load hiện tại
    late final List<Answer> originals;
    try {
      originals = await service.getByQuestionId(questionId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Không tải được đáp án: $e')));
      }
      return null;
    }

    final forms = originals
        .map((a) => AnswerForm(id: a.id, text: a.text, label: a.label))
        .toList();

    final result = await showDialog<List<Answer>?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AnswerEditorBody(
        questionId: questionId,
        originals: originals,
        forms: forms,
        service: service,
      ),
    );

    return result; // caller dùng để update UI ngay
  }
}

class _AnswerEditorBody extends StatefulWidget {
  final int questionId;
  final List<Answer> originals;
  final List<AnswerForm> forms;
  final AnswerService service;

  const _AnswerEditorBody({
    required this.questionId,
    required this.originals,
    required this.forms,
    required this.service,
  });

  @override
  State<_AnswerEditorBody> createState() => _AnswerEditorBodyState();
}

class _AnswerEditorBodyState extends State<_AnswerEditorBody> {
  late List<AnswerForm> _forms;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _forms = List.of(widget.forms);
    if (_forms.isEmpty) _forms.addAll([AnswerForm(text: ''), AnswerForm(text: '')]);
  }

  void _add() => setState(() => _forms.add(AnswerForm(text: '')));
  void _remove(int i) {
    if (_forms.length <= 1) return;
    setState(() => _forms.removeAt(i));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('Sửa đáp án', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context, null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Danh sách đáp án', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton.icon(onPressed: _saving ? null : _add, icon: const Icon(Icons.add), label: const Text('Thêm đáp án')),
                ],
              ),
              const SizedBox(height: 8),

              Expanded(
                child: ListView.separated(
                  itemCount: _forms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final a = _forms[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            // label
                            SizedBox(
                              width: 40,
                              child: TextField(
                                enabled: !_saving,
                                controller: TextEditingController(text: a.label ?? ''),
                                onChanged: (v) => a.label = v.isEmpty ? null : v,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: 'A',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // text
                            Expanded(
                              child: TextField(
                                enabled: !_saving,
                                controller: TextEditingController(text: a.text)
                                  ..selection = TextSelection.collapsed(offset: a.text.length),
                                onChanged: (v) => a.text = v,
                                decoration: const InputDecoration(
                                  hintText: 'Nhập nội dung đáp án...',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            IconButton(
                              tooltip: 'Xoá đáp án',
                              onPressed: _saving ? null : () => _remove(i),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context, null),
                    child: const Text('Huỷ'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                            // validate: ít nhất 1 đáp án có text
                            final cleaned = _forms
                                .map((e) => AnswerForm(id: e.id, text: e.text.trim(), label: e.label?.trim()))
                                .where((e) => e.text.isNotEmpty)
                                .toList();
                            if (cleaned.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nhập ít nhất 1 đáp án')),
                              );
                              return;
                            }

                            setState(() => _saving = true);
                            try {
                              // upsert & auto order = vị trí hiện tại (index + 1)
                              await AnswerApi.upsertAnswers(
                                questionId: widget.questionId,
                                original: widget.originals,
                                edited: cleaned,
                              );
                              // fetch lại để hiển thị ngay
                              final latest = await AnswerApi.fetchAnswers(
                                  questionId: widget.questionId);
                              widget.service.put(widget.questionId, latest);

                              if (context.mounted) Navigator.pop(context, latest);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text('Lưu thất bại: $e')));
                              }
                            } finally {
                              if (mounted) setState(() => _saving = false);
                            }
                          },
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
