import 'package:flutter/material.dart';

class SetStyle {
  final Color bg;
  final Color border;
  final IconData icon;
  final String label;

  const SetStyle({
    required this.bg,
    required this.border,
    required this.icon,
    required this.label,
  });
}

const pageBg = Color(0xFFFDEFF4);

// Hàm sinh style dựa trên tên (hoặc tuỳ bạn định nghĩa quy tắc riêng)
SetStyle buildStyleFromName(String name) {
  final lower = name.toLowerCase();

  // ---- ICON mapping mở rộng ----
  IconData icon = Icons.folder_outlined;
  if (lower.contains('sàng lọc') || lower.contains('screening')) {
    icon = Icons.fact_check_outlined; // sàng lọc
  } else if ((lower.contains('theo dõi') || lower.contains('theo doi')) &&
      (lower.contains('chu kỳ') ||
          lower.contains('chu ki') ||
          lower.contains('cycle'))) {
    icon = Icons.calendar_month_outlined; // theo dõi chu kỳ
  } else if (lower.contains('sau sinh') || lower.contains('postpartum')) {
    icon = Icons.child_care_outlined; // tư vấn sau sinh
  } else if (lower.contains('mang thai') || lower.contains('pregnan')) {
    icon = Icons.pregnant_woman_outlined; // tư vấn mang thai
  } else if (lower.contains('tránh') || lower.contains('contrace')) {
    icon = Icons.shield_outlined; // tránh thai
  } else if (lower.contains('tình dục') || lower.contains('sex')) {
    icon = Icons.favorite_border; // sức khoẻ tình dục
  } else if (lower.contains('cân nặng') || lower.contains('weight')) {
    icon = Icons.monitor_weight_outlined; // cân nặng
  } else if (lower.contains('phụ khoa') || lower.contains('gyne')) {
    icon = Icons.health_and_safety_outlined; // phụ khoa
  }

  // Sinh màu từ tên để bộ nào cũng có màu khác nhau
  final hue = (name.codeUnits.fold<int>(0, (a, b) => (a + b) % 360)).toDouble();
  final bg = HSLColor.fromAHSL(1, hue, 0.8, 0.95).toColor();
  final border = HSLColor.fromAHSL(1, hue, 0.6, 0.75).toColor();

  return SetStyle(bg: bg, border: border, icon: icon, label: name);
}
