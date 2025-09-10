import 'package:flutter/material.dart';
import '../questions/question.dart';
import '../questions/question_service.dart';
import '../questions/question_dialogs.dart';
import '../question_set/QuestionSet.dart';
import '../question_set/QuestionSetAPI.dart';
import '../widgets/question_more_sheet.dart';
import '../pages/question_list_grouped.dart';
import '../answers/answer_editor_dialog.dart';
import '../answers/answer_service.dart';


class QuestionHomePage extends StatefulWidget {
  const QuestionHomePage({super.key});

  @override
  State<QuestionHomePage> createState() => _QuestionHomePageState();
}

class _QuestionHomePageState extends State<QuestionHomePage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _selectedSet;
  final _service = QuestionService();
  List<QuestionSet> _questionSets = [];
  bool _isLoadingSets = true;
  bool _isLoadingQuestions = true;
  final _answerService = AnswerService();
  final Map<int, Key> _answersKeys = {};

  List<Question> get _filtered =>
      _service.filter(keyword: _searchCtrl.text, setName: _selectedSet);

  @override
  void initState() {
    super.initState();
    _loadQuestionSets();
    _loadQuestions();
  }

  Future<void> _loadQuestionSets() async {
    try {
      setState(() => _isLoadingSets = true);
      final sets = await fetchQuestionSets();
      setState(() {
        _questionSets = sets;
        _isLoadingSets = false;
      });
    } catch (e) {
      setState(() => _isLoadingSets = false);
      _snack('Không thể tải danh sách bộ câu hỏi: $e');
    }
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() => _isLoadingQuestions = true);
      await _service.loadQuestions();
      setState(() => _isLoadingQuestions = false);
    } catch (e) {
      setState(() => _isLoadingQuestions = false);
      _snack('Không thể tải danh sách câu hỏi: $e');
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _onEditText(Question q) async {
    final newText = await QuestionDialogs.editText(context, q.text);
    if (newText == null || newText == q.text) return;

    final oldText = q.text;

    // Optimistic UI
    setState(() => _service.updateText(q.id, newText));

    try {
      await _service.patchQuestionText(id: q.id, text: newText);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật nội dung câu hỏi')),
        );
      }
    } catch (e) {
      // rollback nếu lỗi
      setState(() => _service.updateText(q.id, oldText));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thất bại: $e')),
        );
      }
    }
  }

  Future<void> _onEditOrder(Question q) async {
    final newOrder = await QuestionDialogs.editOrder(context, q.order);
    if (newOrder == null || newOrder == q.order) return;

    final old = q.order;
    setState(() => _service.updateOrder(q.id, newOrder));   // optimistic
    try {
      await _service.patchQuestionOrder(q.id, newOrder);
      _snack('Đã lưu thứ tự mới cho #${q.id}');
    } catch (e) {
      setState(() => _service.updateOrder(q.id, old));      // rollback
      _snack('Lưu thất bại: $e');
    }
  }

  Future<void> _onEditPoint(Question q) async {
    // TODO: dialog chỉnh điểm riêng nếu có field
    await _onEditOrder(q);
  }

  Future<void> _onEditAnswers(Question q) async {
    final latest = await AnswerEditorDialog.open(
      context,
      questionId: q.id,
      service: _answerService,
    );
    if (latest != null && mounted) {
      setState(() {
        _answersKeys[q.id] = UniqueKey();          
      });
      await _loadQuestions(); // <-- Thêm dòng này để reload lại danh sách câu hỏi
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã cập nhật đáp án')));
    }
  }

  Future<void> _onDelete(Question q) async {
    final ok = await QuestionDialogs.confirmDelete(context, q.id);
    if (!ok) return;

    try {
      // Reload danh sách trước khi xóa để đảm bảo dữ liệu mới nhất
      await _loadQuestions();
      
      // Thực hiện xóa
      await _service.deleteQuestionApi(id: q.id);
      
      // Reload lại sau khi xóa để cập nhật UI
      if (mounted) {
        await _loadQuestions();
        _snack('Đã xoá câu hỏi thành công');
      }
    } catch (e) {
      if (mounted) {
        await _loadQuestions(); // Reload lại trong trường hợp lỗi
        _snack('Xoá thất bại: $e');
      }
    }
  }

  void _onToggleActive(Question q) async {
    final next = !q.isActive;
    setState(() => _service.setActive(q.id, next)); // optimistic

    try {
      await _service.updateStatus(id: q.id, active: next); // PATCH backend
    } catch (e) {
      setState(() => _service.setActive(q.id, !next)); // rollback
      _snack('Không thể cập nhật trạng thái: $e');
    }
  }

  void _showMoreSheet(Question q) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => QuestionMoreSheet(
        onEdit: () => _onEditText(q),
        onEditPoint: () => _onEditPoint(q),
        onDelete: _onDelete, 
        onEditAnswers: _onEditAnswers,         
        question: q,                  
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sets = (_questionSets.map((e) => e.name).toSet().toList()..sort());

    return Scaffold(
      backgroundColor: const Color(0xFFFDEFF4),
      body: Column(
        children: [
          // search + filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '🔍 Tìm nội dung câu hỏi...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: _isLoadingSets
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<String>(
                          value: _selectedSet?.isEmpty == true ? null : _selectedSet,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(value: '', child: Text('-- Tất cả --')),
                            ...sets.map((s) =>
                                DropdownMenuItem(value: s, child: Text(s))),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedSet = v == '' ? null : v),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // danh sách
          Expanded(
            child: _isLoadingQuestions
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('Không có câu hỏi phù hợp 🤷'))
                    : QuestionListGrouped(
                        questions: _filtered,
                        onAddInSet: (setName) {/* TODO: thêm mới trong set */},
                        onEditText: _onEditText,
                        onDelete: _onDelete,
                        onToggleActive: _onToggleActive,
                        onEditAnswers: _onEditAnswers,  
                        answersKeys: _answersKeys,      
                      ),
          ),
        ],
      ),
    );
  }
}
