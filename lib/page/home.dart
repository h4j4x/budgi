import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../util/collection.dart';
import '../widget/home/categories_expenses.dart';
import '../widget/home/wallets_balance.dart';

final _panels = <_Panel>[
  _Panel(
    headerBuilder: (context) {
      return Text(L10n.of(context).walletsBalance);
    },
    bodyBuilder: (context) {
      return const WalletsBalance();
    },
  ),
  _Panel(
    headerBuilder: (context) {
      return Text(L10n.of(context).categoriesExpenses);
    },
    bodyBuilder: (context) {
      return const CategoriesExpenses();
    },
  ),
];

class HomePage extends StatefulWidget {
  static const route = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPanel = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            setState(() {
              if (isExpanded) {
                selectedPanel = index;
              } else {
                selectedPanel = -1;
              }
            });
          },
          children: _panels.mapIndexed<ExpansionPanel>((index, panel) {
            return ExpansionPanel(
              canTapOnHeader: true,
              headerBuilder: (context, isExpanded) {
                return ListTile(
                  selected: selectedPanel == index,
                  dense: isExpanded,
                  title: panel.headerBuilder(context),
                );
              },
              body: panel.bodyBuilder(context),
              isExpanded: selectedPanel == index,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Panel {
  final WidgetBuilder headerBuilder;
  final WidgetBuilder bodyBuilder;

  _Panel({
    required this.headerBuilder,
    required this.bodyBuilder,
  });
}
