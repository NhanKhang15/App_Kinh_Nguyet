import 'package:flutter/material.dart';

class QuestionDialogs {
  /// Mở dialog sửa nội dung, trả về text mới (null nếu huỷ)
  static Future<String?> editText(
      BuildContext context, String currentText) async {
    final ctrl = TextEditingController(text: currentText);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('✏️ Sửa nội dung câu hỏi'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Nhập nội dung mới...',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Lưu')),
        ],
      ),
    );
    if (ok == true) {
      final text = ctrl.text.trim();
      return text.isEmpty ? null : text;
    }
    return null;
  }

  /// Mở dialog cập nhật thứ tự, trả về order mới (null nếu huỷ)
  static Future<int?> editOrder(BuildContext context, int currentOrder) async {
    final ctrl = TextEditingController(text: currentOrder.toString());
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔢 Cập nhật thứ tự'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Nhập số thứ tự...',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Lưu')),
        ],
      ),
    );
    if (ok == true) {
      final v = int.tryParse(ctrl.text.trim());
      if (v != null && v >= 0) return v;
    }
    return null;
  }

  /// Confirm xoá, true nếu đồng ý
  static Future<bool> confirmDelete(BuildContext context, int id) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🗑️ Xoá câu hỏi'),
        content: const Text('Bạn có chắc chắn muốn xóa câu hỏi này?\n\nLưu ý:\n- Tất cả câu trả lời sẽ bị xóa\n- Thứ tự các câu hỏi sẽ được cập nhật lại'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Không')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xoá luôn')),
        ],
      ),
    );
    return yes == true;
  }
}
