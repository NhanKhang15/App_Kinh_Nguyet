import 'package:flutter/material.dart';
import 'ques_ans_model.dart';
import 'question_service.dart';
import '../../../constants/config.dart';
import '../menstrual_cycle_tracking/UserAnswerApi.dart';
import '../widgets/user_account.dart';

class Tracking extends StatefulWidget {
  final int setId;                 // ✅ bộ câu hỏi
  final int startOrdinal;          // ✅ bắt đầu từ câu thứ mấy (1-based)
  final QuestionService service;
  final UserAccount userAccount;

  Tracking({
    super.key,
    required this.userAccount,
    this.setId = 1,
    this.startOrdinal = 1,
    QuestionService? service,
  }) : service = service ?? QuestionService(baseUrl: AppConfig.baseUrl);

  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  late int _ordinal;                               // 1-based
  late Future<OrdinalQuestionResult> _future;      // dữ liệu hiện tại
  int _currentQuestionId = 0;                      // ✅ ID thật trong DB để lưu
  int _totalQuestions = 1;                         // tổng trong set (active)
  int? _selectedAnswerId;

  final _userAnswerApi = UserAnswerApi();
  bool _savingNext = false;
  final int? _cycleId = null; // TODO: set khi có

  @override
  void initState() {
    super.initState();
    _ordinal = widget.startOrdinal;
    _future = _load();
  }

  // Gọi API theo ordinal, cache questionId/total cho Next/Back/progress
  Future<OrdinalQuestionResult> _load() async {
    final res = await widget.service.getByOrdinal(
      setId: widget.setId,
      ordinal: _ordinal,
      active: true,
    );
    if (res.total <= 0) {
      throw Exception('Bộ câu hỏi trống (total = 0)');
    }
    // nếu admin vừa đổi active làm giảm total → kéo ordinal về cuối
    if (_ordinal > res.total) _ordinal = res.total;

    _currentQuestionId = res.question.id; // dùng để upsert answer
    _totalQuestions = res.total;
    return res;
  }

  Future<void> _goNext() async {
    if (_selectedAnswerId == null || _selectedAnswerId! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID đáp án không hợp lệ')),
      );
      return;
    }
    if (_savingNext) return;

    setState(() => _savingNext = true);

    try {
      final status = await _userAnswerApi.upsertAnswer(
        userAccount: widget.userAccount,
        questionId: _currentQuestionId,     // ✅ luôn dùng ID DB, KHÔNG dùng ordinal
        answerId: _selectedAnswerId!,
        cycleId: _cycleId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status == 'created' ? 'Đã lưu' : 'Đã cập nhật')),
      );

      final isLast = _ordinal >= _totalQuestions;
      if (!isLast) {
        setState(() {
          _ordinal += 1;
          _selectedAnswerId = null;
          _future = _load();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hoàn thành bộ câu hỏi 🎉')),
        );
        // OPTIONAL: điều hướng trang kết thúc
        // if (!mounted) return;
        // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const NextPage()));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi khi lưu: $e')));
    } finally {
      if (mounted) setState(() => _savingNext = false);
    }
  }

  void _goBack() {
    if (_ordinal <= 1) return;
    setState(() {
      _ordinal -= 1;
      _selectedAnswerId = null;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<OrdinalQuestionResult>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                // ignore: avoid_print
                print('Error loading question: ${snapshot.error}');
                return _ErrorBox(
                  message: 'Không thể tải câu hỏi: ${snapshot.error}',
                  onRetry: () => setState(() => _future = _load()),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('Không có dữ liệu'));
              }

              final result = snapshot.data!;
              final question = result.question;
              final ord = question.ordinal > 0 ? question.ordinal : _ordinal;
              final total = result.total <= 0 ? 1 : result.total;
              final percent = (ord / total).clamp(0.0, 1.0);
              final isLast = ord >= result.total;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header progress
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Theo dõi chu kỳ kinh nguyệt',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${(percent * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 23, color: Colors.pink, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Câu hỏi $ord/${result.total}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(isLast ? 'Hoàn thành' : '',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            borderRadius: BorderRadius.circular(14),
                            value: percent,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // WHITE BOX: Question + Answers
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.text.isEmpty ? '(Chưa có câu hỏi)' : question.text,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),

                          if (question.answers.isEmpty)
                            const Text('Chưa có đáp án cho câu này',
                                style: TextStyle(color: Colors.grey)),

                          ...question.answers.map((ans) {
                            final isSelected = _selectedAnswerId == ans.id;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedAnswerId = ans.id),
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.pink[50] : Colors.white,
                                  border: Border.all(
                                    color: isSelected ? Colors.pink : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ans.text,
                                  style: TextStyle(
                                    color: isSelected ? Colors.pink : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: ord > 1 ? _goBack : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.arrow_back),
                              SizedBox(width: 6),
                              Text('Quay lại'),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: (_selectedAnswerId != null && !_savingNext) ? _goNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _savingNext
                              ? const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(isLast ? 'Hoàn thành' : 'Tiếp tục'),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Trang tiếp theo')),
    );
  }
}
