// add_question_page.dart
import 'package:flutter/material.dart';
import 'add_queestion/add_question_actions.dart';
import 'pages/add_question_top_page.dart';
import '../list_of_questions/questions/question_service.dart';
import '../list_of_questions/answers/answer_service.dart';

class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key});
  @override
  State<AddQuestionPage> createState() => _AddQuestionPage();
}

class _AddQuestionPage extends State<AddQuestionPage> {
  late final AddQuestionActions ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = AddQuestionActions(
      service: QuestionService(),
      answerService: AnswerService(),
    );
  }

  @override
  Widget build(BuildContext context) => AddQuestionTopPage(ctrl: ctrl);

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }
}
