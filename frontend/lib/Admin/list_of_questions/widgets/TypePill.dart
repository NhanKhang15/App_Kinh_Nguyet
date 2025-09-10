import 'package:flutter/material.dart';

class TypePill extends StatelessWidget {
  final String? type; // "single" | "multiple" | "text" | null
  const TypePill({this.type});

  String get _label {
    switch ((type ?? '').toLowerCase()) {
      case 'single':
        return 'Một lựa chọn';
      case 'multiple':
        return 'Nhiều lựa chọn';
      case 'text':
        return 'Nhập tự do';
      default:
        return 'Loại khác';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.label_outline, size: 16),
          const SizedBox(width: 6),
          Text(_label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
