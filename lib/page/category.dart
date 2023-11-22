import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../model/category.dart';
import '../widget/category_edit.dart';

class CategoryPage extends StatelessWidget {
  static const route = '/category';

  final Category? value;

  const CategoryPage({
    super.key,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final action = value != null ? l10n.editAction : l10n.createAction;
    return Scaffold(
      appBar: AppBar(
        title: Text('$action ${l10n.budgetCategory.toLowerCase()}'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: CategoryEdit(
          value: value,
        ),
      ),
    );
  }
}
