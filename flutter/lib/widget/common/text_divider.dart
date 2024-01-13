import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  final Color color;
  final String text;

  const TextDivider({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Text(
          text,
          textScaler: const TextScaler.linear(0.6),
          style: TextStyle(color: color),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}
