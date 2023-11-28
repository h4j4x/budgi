import 'package:flutter/material.dart';

class SliverCenter extends StatelessWidget {
  final Widget child;

  const SliverCenter({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: child,
      ),
    );
  }
}
