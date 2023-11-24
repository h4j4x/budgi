import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../di.dart';
import '../../l10n/l10n.dart';
import '../../model/period.dart';
import '../../model/wallet.dart';
import '../../service/wallet.dart';
import '../../util/datetime.dart';

class WalletsBalance extends StatefulWidget {
  const WalletsBalance({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WalletsBalanceState();
  }
}

class _WalletsBalanceState extends State<WalletsBalance> {
  final periodController = TextEditingController();
  final wallets = <Wallet>[];
  final walletsMap = <Wallet, double>{};

  bool loading = false;

  Period period = Period.currentMonth;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      periodController.text = formatDateTimePeriod(
        context,
        period: period,
      );
      loadMap();
    });
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
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }
    return body();
  }

  Widget body() {
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
      title: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        child: TextField(
          controller: periodController,
          decoration: InputDecoration(
            icon: AppIcon.calendar,
          ),
          readOnly: true,
          enabled: false,
        ),
      ),
      actions: [
        IconButton(
          onPressed: loadMap,
          icon: AppIcon.reload,
        ),
      ],
    );
  }

  Widget list() {
    return SliverList.separated(
      itemBuilder: (_, index) {
        if (wallets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(L10n.of(context).nothingHere),
            ),
          );
        }
        return listItem(wallets[index]);
      },
      separatorBuilder: (_, __) {
        return const Divider();
      },
      itemCount: wallets.isNotEmpty ? wallets.length : 1,
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
