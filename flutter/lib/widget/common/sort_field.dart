import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../l10n/l10n.dart';
import '../../util/function.dart';
import '../../model/sort.dart';
import 'select_field.dart';

class SortField extends StatelessWidget {
  final bool mobileSize;
  final Sort value;
  final String title;
  final TypedCallback<Sort>? onChanged;

  const SortField({
    super.key,
    required this.mobileSize,
    required this.value,
    required this.title,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return mobileSize ? mobile(context) : desktop();
  }

  Widget mobile(BuildContext context) {
    return IconButton(
      onPressed: onChanged != null
          ? () async {
              final selectedValue = await showDialog<Sort?>(
                context: context,
                builder: (context) {
                  final l10n = L10n.of(context);
                  return AlertDialog(
                    title: Text(title),
                    content: listOptions(context),
                    actions: [
                      TextButton(
                        onPressed: context.pop,
                        child: Text(l10n.cancelAction),
                      ),
                    ],
                  );
                },
              );
              if (selectedValue != null) {
                onChanged!(selectedValue);
              }
            }
          : null,
      icon: value.icon(),
    );
  }

  Widget listOptions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: Sort.values.map((sort) {
        return ListTile(
          leading: sort.icon(),
          title: Text(sort.l10n(context)),
          onTap: () {
            context.pop(sort);
          },
        );
      }).toList(),
    );
  }

  Widget desktop() {
    return SelectField<Sort>(
      selectedValue: value,
      items: Sort.values,
      itemBuilder: (context, item) {
        return Text(item.l10n(context));
      },
      icon: value.icon(),
      iconBuilder: (_, item) {
        return item.icon();
      },
      onChanged: onChanged,
    );
  }
}
