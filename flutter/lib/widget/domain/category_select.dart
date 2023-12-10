import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../model/domain/category.dart';
import '../common/select_field.dart';

class CategorySelect extends StatelessWidget {
  final List<Category>? list;
  final Category? value;
  final Function(Category?) onChanged;
  final String? hintText;
  final String? errorText;
  final bool enabled;

  const CategorySelect({
    super.key,
    required this.list,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SelectField<Category>(
      items: list ?? [],
      itemBuilder: (context, value) {
        return Text(value.name);
      },
      onClear: enabled
          ? () {
              onChanged(null);
            }
          : null,
      onChanged: enabled
          ? (value) {
              onChanged(value);
            }
          : null,
      selectedValue: value,
      icon: list == null ? AppIcon.loading : AppIcon.category,
      hintText: hintText,
      errorText: errorText,
    );
  }
}
