import 'package:flutter/material.dart';
import '../../list_of_questions/question_set/QuestionSet.dart';
import '../../list_of_questions/question_set/QuestionSetAPI.dart';
import '../../list_of_questions/questions/question.dart';
import '../../list_of_questions/questions/question_service.dart';
import '../../list_of_questions/answers/answer_service.dart';
import '../add_answer/answer_form.dart';

class AddQuestionActions extends ChangeNotifier {
  // Inject services
  final QuestionService service;
  final AnswerService answerService;
  
  AddQuestionActions({
    required this.service, 
    required this.answerService
  }) {
    _loadQuestionSets();
  }

  // ... các field cũ
  List<QuestionSet> sets = [];
  String? selectedSetId;

  int typeIndex = 0; // 0=single, 1=multiple, 2=text
  final TextEditingController questionTextCtrl = TextEditingController();

  // NEW: state để map với UI
  bool isActive = true;
  int? manualOrder; // null => để backend tự append

  // answers / rules y như cũ
  final List<AnswerForm> answers = [];
  final List<Map<String, String?>> rules = [];

  bool saving = false;


  Future<void> _loadQuestionSets() async {
    try {
      sets = await fetchQuestionSets();
      notifyListeners();
    } catch (e) {
      print('Error loading question sets: $e');
    }
  }
  // ---- mutations ----
  void setSetId(String? id) {
    selectedSetId = id;
    notifyListeners();
  }

  void changeType(int index) {
    if (typeIndex == index) return;
    typeIndex = index;
    _resetForType();
    notifyListeners();
  }

  void _resetForType() {
    answers.clear();
    rules.clear();
    if (!isTextType) addAnswer();
  }

  bool get isTextType => typeIndex == 2;
  bool get showCombination => typeIndex == 1;

  void addAnswer() {
    final label = String.fromCharCode(65 + answers.length); // A, B, C...
    answers.add(AnswerForm(label: label, text: ''));
    notifyListeners();
  }

  void removeAnswer(int index) {
    answers.removeAt(index);
    // Cập nhật lại labels
    for (var i = 0; i < answers.length; i++) {
      answers[i].label = String.fromCharCode(65 + i);
    }
    notifyListeners();
  }

  void updateAnswer(int index, {String? text, String? hint}) {
    final a = answers[index];
    if (text != null) a.text = text;
    notifyListeners();
  }

  void addRule() {
    rules.add({'combination': '', 'next': null});
    notifyListeners();
  }

  void removeRule(int index) {
    rules.removeAt(index);
    notifyListeners();
  }

  void updateRule(int index, {String? combination, String? next}) {
    final r = rules[index];
    if (combination != null) r['combination'] = combination;
    if (next != null) r['next'] = next;
    notifyListeners();
  }

  String? validate() {
    if (questionTextCtrl.text.trim().isEmpty) return 'Nhập nội dung câu hỏi';
    if (!isTextType) {
      if (answers.isEmpty) return 'Cần ít nhất 1 đáp án';
      final ok = answers.every((a) => a.text.trim().isNotEmpty);
      if (!ok) return 'Một số đáp án còn trống';
    }
    if (showCombination) {
      for (final r in rules) {
        if ((r['combination'] ?? '').trim().isEmpty || (r['next'] ?? '').toString().isEmpty) {
          return 'Tổ hợp rẽ nhánh chưa đủ thông tin';
        }
      }
    }
    return null;
  }

  Future<Question> save(BuildContext context) async {
    final err = validate();
    if (err != null) throw Exception(err);

    saving = true;
    notifyListeners();

    try {
      final question = await submitCreate(context);
      
      // Reset form sau khi lưu thành công
      questionTextCtrl.clear();
      setSetId(null);
      changeType(0);
      
      return question;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    questionTextCtrl.dispose();
    super.dispose();
  }

Future<Question> submitCreate(BuildContext ctx) async {
    // validate cơ bản
    if (selectedSetId == null) {
      throw Exception('Vui lòng chọn Bộ câu hỏi');
    }
    final text = questionTextCtrl.text.trim();
    if (text.isEmpty) {
      throw Exception('Nội dung câu hỏi không được để trống');
    }

    saving = true; 
    notifyListeners();
    try {
      final setId = int.parse(selectedSetId!);
      final typeId = typeIdFromIndex(typeIndex);

      // 1. Tạo câu hỏi trước
      final q = await service.createQuestion(
        questionText: text,
        questionSetId: setId,
        typeId: typeId,
        orderInSet: manualOrder,   // null => append
        isActive: isActive,
      );

      // 2. Nếu không phải text type, tạo các câu trả lời
      if (!isTextType && answers.isNotEmpty) {
        int order = 1;
        for (final answer in answers) {
          if (answer.text.trim().isEmpty) continue;
          
          await answerService.createAnswer(
            questionId: q.id,
            text: answer.text.trim(),
            label: answer.label,
            orderInQuestion: order++,
          );
        }
      }

      return q;
    } finally {
      saving = false; 
      notifyListeners();
    }
  }
}

// helpers
String typeIdFromIndex(int idx) {
  switch (idx) {
    case 0: return 'single';
    case 1: return 'multiple';
    case 2: return 'text';
    default: return 'single';
  }
}