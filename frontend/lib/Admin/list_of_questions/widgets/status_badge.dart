import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final bool active;
  const StatusBadge({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.green : Colors.red;
    final text = active ? 'Hoạt động' : 'Ngưng';
    final icon = active ? Icons.check_circle : Icons.block;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
