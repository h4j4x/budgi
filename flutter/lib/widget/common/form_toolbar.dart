import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../l10n/l10n.dart';

class FormToolbar extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onCancel;
  final VoidCallback onSave;

  const FormToolbar({
    super.key,
    required this.enabled,
    this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        button(
          context,
          text: L10n.of(context).cancelAction,
          onAction: () {
            if (onCancel != null) {
              onCancel!();
            } else {
              context.pop();
            }
          },
        ),
        button(
          context,
          text: L10n.of(context).saveAction,
          onAction: onSave,
        ),
      ],
    );
  }

  Widget button(
    BuildContext context, {
    required String text,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150, minWidth: 100),
        child: ElevatedButton(
          onPressed: enabled ? onAction : null,
          child: Text(text),
        ),
      ),
    );
  }
}
