import 'package:flutter/material.dart';

class SelectAnswer extends StatefulWidget {
  final String label;
  final String text;
  final VoidCallback onRemove;
  final ValueChanged<String> onTextChanged;
  
  const SelectAnswer({
    required this.label,
    required this.text,
    required this.onRemove,
    required this.onTextChanged,
  });

  @override
  @override
  State<SelectAnswer> createState() => _SelectAnswerState();
}

class _SelectAnswerState extends State<SelectAnswer> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(12),
        border:
            const Border(left: BorderSide(color: Color(0xFFBDB3FF), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.label}.', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _textController,
            onChanged: widget.onTextChanged,
            decoration: const InputDecoration(
              hintText: 'Nội dung đáp án',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: widget.onRemove,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Xoá'),
            ),
          ),
        ],
      ),
    );
  }
}
