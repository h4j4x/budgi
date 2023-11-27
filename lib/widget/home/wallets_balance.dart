import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../model/wallet.dart';
import '../../service/wallet.dart';
import '../common/month_field.dart';
import '../common/responsive.dart';
import '../common/sort_field.dart';

class WalletsBalance extends StatefulWidget {
  const WalletsBalance({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletsBalanceState();
  }
}

class _WalletsBalanceState extends State<WalletsBalance> {
  final wallets = <Wallet>[];
  final walletsMap = <Wallet, double>{};

  bool loading = false;

  Period period = Period.currentMonth;
  Sort amountSort = Sort.desc;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, loadMap);
  }

  void loadMap() async {
    if (loading) {
      return;
    }
    setState(() {
      loading = true;
    });
    final values =
        await DI().get<WalletService>().walletsBalance(period: period);
    wallets.clear();
    wallets.addAll(values.keys);
    walletsMap.clear();
    walletsMap.addAll(values);
    sortKeys();
  }

  void sortKeys() {
    wallets.sort((w1, w2) {
      if (amountSort == Sort.asc) {
        return walletsMap[w1]!.compareTo(walletsMap[w2]!);
      }
      return walletsMap[w2]!.compareTo(walletsMap[w1]!);
    });
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(mobile: body(true), desktop: body(false));
  }

  Widget body(bool mobileSize) {
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        toolbar(mobileSize),
        list(),
      ],
    );
  }

  Widget toolbar(bool mobileSize) {
    return SliverAppBar(
      toolbarHeight: kToolbarHeight + 16,
      title: MonthFieldWidget(
        period: period,
        onChanged: !loading
            ? (value) {
                period = value;
                loadMap();
              }
            : null,
      ),
      actions: [
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.only(right: 4),
          child: SortField(
              mobileSize: mobileSize,
              title: L10n.of(context).sortByAmount,
              value: amountSort,
              onChanged: !loading && wallets.isNotEmpty
                  ? (value) {
                      amountSort = value;
                      sortKeys();
                    }
                  : null),
        ),
        IconButton(
          onPressed: !loading ? loadMap : null,
          icon: AppIcon.reload,
        ),
      ],
    );
  }

  Widget list() {
    return SliverList.separated(
      itemBuilder: (_, index) {
        if (loading || wallets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: loading
                  ? const CircularProgressIndicator.adaptive()
                  : Text(L10n.of(context).nothingHere),
            ),
          );
        }
        return listItem(wallets[index]);
      },
      separatorBuilder: (_, __) {
        return const Divider();
      },
      itemCount: wallets.isNotEmpty && !loading ? wallets.length : 1,
    );
  }

  Widget listItem(Wallet item) {
    final amount = walletsMap[item] ?? 0;
    return ListTile(
      leading: item.walletType.icon(),
      title: Text(item.name),
      subtitle: Text('\$${amount.toStringAsFixed(2)}'),
    );
  }
}
