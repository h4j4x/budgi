import 'package:flutter/material.dart';

import '../../app/config.dart';
import '../../app/router.dart';
import '../../di.dart';
import '../../model/error/validation.dart';
import '../../l10n/l10n.dart';
import '../../model/domain/category.dart';
import '../../model/error/category.dart';
import '../../service/category.dart';
import '../../service/impl/category_validator.dart';
import '../../service/spring/http_client.dart';
import '../../util/ui.dart';
import '../common/form_toolbar.dart';

class CategoryEdit extends StatefulWidget {
  final Category? value;

  const CategoryEdit({
    super.key,
    this.value,
  });

  @override
  State<StatefulWidget> createState() {
    return _CategoryEditState();
  }
}

class _CategoryEditState extends State<CategoryEdit> {
  final nameController = TextEditingController();
  final errors = <String, CategoryError>{};

  bool saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      nameController.text = widget.value!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      categoryNameField(),
      const SizedBox(height: 24),
      FormToolbar(enabled: !saving, onSave: onSave),
    ];
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.separated(
          itemBuilder: (_, index) {
            return items[index];
          },
          separatorBuilder: (_, __) {
            return const Divider(color: Colors.transparent);
          },
          itemCount: items.length,
        ),
      ),
    );
  }

  Widget categoryNameField() {
    final l10n = L10n.of(context);
    return TextField(
      controller: nameController,
      textInputAction: TextInputAction.go,
      autofocus: true,
      maxLength: AppConfig.textFieldMaxLength,
      enabled: !saving,
      decoration: InputDecoration(
        labelText: l10n.categoryName,
        hintText: l10n.categoryNameHint,
        errorText: errors[CategoryValidator.name]?.l10n(context),
      ),
      onChanged: (_) {
        setState(() {
          errors.remove(CategoryValidator.name);
        });
      },
      onSubmitted: (_) {
        onSave();
      },
    );
  }

  void onSave() async {
    if (saving) {
      return;
    }
    setState(() {
      errors.clear();
      saving = true;
    });
    try {
      await DI().get<CategoryService>().saveCategory(
            code: widget.value?.code,
            name: nameController.text,
          );
      if (mounted) {
        context.pop();
      }
    } on ValidationError<CategoryError> catch (e) {
      errors.addAll(e.errors);
    } on HttpError catch (e) {
      if (mounted) {
        context.showError(e.l10n(context));
      }
    } finally {
      setState(() {
        saving = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
