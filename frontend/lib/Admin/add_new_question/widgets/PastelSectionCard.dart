import 'package:flutter/material.dart';

class PastelSectionCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? leading;
  final EdgeInsets padding;
  const PastelSectionCard({
    required this.child,
    this.title,
    this.leading,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 14,
              offset: const Offset(0, 6))
        ],
        border: Border.all(color: const Color(0xFFEDEAFF)),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 8)],
                  Text(title!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
            if (title != null) const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
