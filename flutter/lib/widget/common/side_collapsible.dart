import 'package:flutter/material.dart';

class SideCollapsibleWidget extends StatelessWidget {
  final bool sideCollapsed;
  final Widget side;
  final Widget child;

  const SideCollapsibleWidget({
    super.key,
    required this.sideCollapsed,
    required this.side,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: sideCollapsed ? 60 : 320,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          child: side,
        ),
        Expanded(child: child),
      ],
    );
  }
}
