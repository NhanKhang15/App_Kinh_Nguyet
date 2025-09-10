import 'package:flutter/material.dart';
import '../questions/question.dart';
import '../question_set/set_styles.dart';
import '../pages/SetHeader.dart';
import '../widgets/toggle_active_button.dart';
import '../widgets/TypePill.dart';
import '../questions/question_service.dart';
import '../answers/widgets/answer_list.dart';
import '../answers/answer_service.dart';

class ReorderableSetList extends StatefulWidget {
  final String setName;
  final List<Question> items;
  final void Function(String setName) onAddInSet;
  final void Function(Question) onEditText;
  final Future<void> Function(Question) onDelete;
  final void Function(Question) onToggleActive;
  final void Function(Question) showMoreSheet;

  /// NEW: map để ép AnswerList rebuild theo questionId
  final Map<int, Key>? answersKeys;

  const ReorderableSetList({
    super.key,
    required this.setName,
    required this.items,
    required this.onAddInSet,
    required this.onEditText,
    required this.onDelete,
    required this.onToggleActive,
    required this.showMoreSheet,
    this.answersKeys,
  });

  @override
  State<ReorderableSetList> createState() => _ReorderableSetListState();
}

class _ReorderableSetListState extends State<ReorderableSetList> {
  late List<Question> _list;
  final _service = QuestionService();
  final _answerService = AnswerService();

  @override
  void initState() {
    super.initState();
    _list = List.of(widget.items);
  }

  @override
  void didUpdateWidget(covariant ReorderableSetList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _list = List.of(widget.items);
  }

  void _renumberLocal() {
    for (int i = 0; i < _list.length; i++) {
      _list[i].order = i + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = buildStyleFromName(widget.setName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SetHeader(
            setName: widget.setName,
            style: style,
            total: _list.length,
            onAdd: () => widget.onAddInSet(widget.setName),
          ),
        ),
        ReorderableListView.builder(
          key: PageStorageKey('set-${widget.setName}'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _list.length,
          onReorder: (oldIndex, newIndex) async {
            if (newIndex > oldIndex) newIndex -= 1;

            final moved = _list.removeAt(oldIndex);
            _list.insert(newIndex, moved);

            _renumberLocal();
            setState(() {});

            final targetIndex = newIndex + 1;
            try {
              await _service.moveTo(id: moved.id, targetIndex: targetIndex);
            } catch (e) {
              final back = _list.removeAt(newIndex);
              _list.insert(oldIndex, back);
              _renumberLocal();
              setState(() {});
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không lưu được vị trí: $e')),
                );
              }
            }
          },
          proxyDecorator: (child, index, anim) => Material(elevation: 3, child: child),
          itemBuilder: (ctx, i) {
            final q = _list[i];
            final style = buildStyleFromName(q.setName);

            return Padding(
              key: ValueKey('q-${q.id}'),
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: q.isActive ? 1.0 : 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    color: style.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: style.border, width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ReorderableDragStartListener(
                              index: i,
                              child: const Icon(Icons.drag_indicator,
                                  size: 18, color: Colors.black54),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${q.order}.',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(style.icon, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                style.label,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ToggleActiveButton(
                              questionId: q.id,
                              active: q.isActive,
                              onChanged: (_) => widget.onToggleActive(q),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => widget.showMoreSheet(q),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Text(
                          q.text,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        AnswerList(
                          key: (widget.answersKeys != null)
                              ? widget.answersKeys![q.id]
                              : ValueKey('ans-${q.id}'),
                          questionId: q.id,
                          service: _answerService,
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            TypePill(type: q.type),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
