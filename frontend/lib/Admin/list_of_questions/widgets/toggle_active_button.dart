import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


class ToggleActiveButton extends StatefulWidget {
  final int questionId;
  final bool active;
  final ValueChanged<bool>? onChanged;

  const ToggleActiveButton({
    super.key,
    required this.questionId,
    required this.active,
    this.onChanged,
  });

  @override
  State<ToggleActiveButton> createState() => _ToggleActiveButtonState();
}

class _ToggleActiveButtonState extends State<ToggleActiveButton> {
  late bool _active = widget.active;
  bool _loading = false;

  @override
  void didUpdateWidget(covariant ToggleActiveButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _active = widget.active;
  }

  Future<void> _handleTap() async {
    if (_loading) return;
    final next = !_active;
    setState(() {
      _active = next; // optimistic trong nút
      _loading = true;
    });
    try {
      // Không gọi API trực tiếp ở đây: để parent làm và có rollback tổng thể
      widget.onChanged?.call(next);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _active ? Colors.green : Colors.grey;
    final text  = _active ? 'Hoạt động' : 'Ngưng';
    final icon  = _active ? Icons.check : Icons.pause;

    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loading)
              const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
            else
              Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
