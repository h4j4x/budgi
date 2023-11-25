import 'package:flutter/material.dart';

import '../../model/callback.dart';

typedef TypedWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class SelectField<T> extends StatelessWidget {
  final List<T> items;
  final TypedWidgetBuilder<T> itemBuilder;
  final TypedCallback<T>? onChanged;
  final T? selectedValue;
  final Widget? icon;
  final TypedWidgetBuilder<T>? iconBuilder;
  final String? hintText;
  final String? errorText;

  const SelectField({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onChanged,
    this.selectedValue,
    this.icon,
    this.iconBuilder,
    this.hintText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      items: items.map((value) {
        return _itemOption(context, value);
      }).toList(),
      selectedItemBuilder: (context) {
        return items.map((value) {
          return _itemOption(context, value, false);
        }).toList();
      },
      value: selectedValue,
      decoration: InputDecoration(
        icon: _icon(context),
        hintText: hintText,
        errorText: errorText,
      ),
      isExpanded: true,
      onChanged: onChanged != null
          ? (selected) {
              if (selected != null) {
                onChanged!(selected);
              }
            }
          : null,
    );
  }

  Widget? _icon(BuildContext context) {
    if (selectedValue != null && iconBuilder != null) {
      return iconBuilder!(context, selectedValue as T);
    }
    return icon;
  }

  DropdownMenuItem<T> _itemOption(
    BuildContext context,
    T value, [
    bool withIcon = true,
  ]) {
    Widget child = itemBuilder(context, value);
    if (withIcon && iconBuilder != null) {
      child = Row(
        children: [
          iconBuilder!(context, value),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: child,
          ),
        ],
      );
    }
    return DropdownMenuItem<T>(
      value: value,
      enabled: value != selectedValue,
      child: child,
    );
  }
}
