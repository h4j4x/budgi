import 'package:budgi/di.dart';
import 'package:budgi/model/budget_category.dart';
import 'package:flutter/material.dart';

import 'common/max_width.dart';

class BudgetCategoryEdit extends StatefulWidget {
  final BudgetCategoryAmount? value;
  final DateTime fromDate;
  final DateTime toDate;

  const BudgetCategoryEdit({
    super.key,
    this.value,
    required this.fromDate,
    required this.toDate,
  });

  @override
  State<StatefulWidget> createState() {
    return _BudgetCategoryEditState();
  }
}

class _BudgetCategoryEditState extends State<BudgetCategoryEdit> {
  final nameController = TextEditingController();

  bool saving = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.value?.budgetCategory.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Text(
        'CATEGGG TODO', // TODO
        textScaleFactor: 1.2,
      ),
      TextField(
        controller: nameController,
        textInputAction: TextInputAction.next,
        autofocus: true,
        maxLength: 200,
        enabled: !saving,
        decoration: const InputDecoration(
          labelText: 'Category name', // TODO
          hintText: 'Enter category name...', // TODO
        ),
      ),
      Center(
        child: MaxWidthWidget(
          maxWidth: 150,
          child: ElevatedButton(
            onPressed: saving ? null : onSave,
            child: const Text('SAVE TODO'), // TODO
          ),
        ),
      ),
    ];
    return ListView.separated(
      itemBuilder: (_, index) {
        return items[index];
      },
      separatorBuilder: (_, __) {
        return const Divider(color: Colors.transparent);
      },
      itemCount: items.length,
    );
  }

  void onSave() async {
    if (saving) {
      return;
    }
    setState(() {
      saving = true;
    });
    await DI().budgetCategoryService().saveAmount(
          categoryCode: widget.value?.budgetCategory.code,
          categoryName: nameController.text,
          fromDate: widget.fromDate,
          toDate: widget.toDate,
          amount: 1.0, // TODO
        );
    setState(() {
      saving = false;
    });
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
