import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../model/period.dart';
import '../../model/wallet.dart';
import '../../service/wallet.dart';
import '../common/month_input.dart';

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
    final values = await DI().get<WalletService>().walletsBalance(period: period);
    wallets.clear();
    wallets.addAll(values.keys);
    walletsMap.clear();
    walletsMap.addAll(values);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        toolbar(),
        list(),
      ],
    );
  }

  Widget toolbar() {
    return SliverAppBar(
      toolbarHeight: kToolbarHeight + 16,
      title: MonthInputWidget(
        period: period,
        onChange: !loading
            ? (value) {
                period = value;
                loadMap();
              }
            : null,
      ),
      actions: [
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
              child: loading ? const CircularProgressIndicator.adaptive() : Text(L10n.of(context).nothingHere),
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
