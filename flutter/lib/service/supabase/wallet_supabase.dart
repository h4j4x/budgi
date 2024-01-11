import 'package:supabase_flutter/supabase_flutter.dart';

import '../../di.dart';
import '../../model/data_page.dart';
import '../../model/domain/user.dart';
import '../../model/domain/wallet.dart';
import '../../model/error/validation.dart';
import '../../model/error/wallet.dart';
import '../../model/fields.dart';
import '../../model/period.dart';
import '../../model/sort.dart';
import '../../util/string.dart';
import '../auth.dart';
import '../transaction.dart';
import '../validator.dart';
import '../wallet.dart';
import 'config.dart';

const walletTable = 'wallets';

class WalletSupabaseService implements WalletService {
  final SupabaseConfig config;
  final Validator<Wallet, WalletError>? walletValidator;

  WalletSupabaseService({
    required this.config,
    this.walletValidator,
  });

  @override
  Future<Wallet> saveWallet({
    String? code,
    required WalletType walletType,
    required String name,
  }) async {
    final user = DI().get<AuthService>().fetchUser(errorIfMissing: WalletError.invalidUser);

    final walletCode = code ?? randomString(6);
    final wallet = SupabaseWallet(code: walletCode, walletType: walletType, name: name);
    final errors = walletValidator?.validate(wallet);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError<WalletError>(errors!);
    }

    final walletExists = await _walletExistsByCode(walletCode);
    if (walletExists) {
      await config.supabase.from(walletTable).update(wallet.toMap(user)).match({codeField: walletCode});
    } else {
      await config.supabase.from(walletTable).insert(wallet.toMap(user));
    }
    return wallet;
  }

  @override
  Future<DataPage<Wallet>> listWallets({
    List<String>? excludingCodes,
  }) async {
    final user = DI().get<AuthService>().user();
    if (user == null) {
      return DataPage.empty();
    }

    var query = config.supabase.from(walletTable).select().eq(userIdField, user.id);
    if (excludingCodes?.isNotEmpty ?? false) {
      query = query.not(codeField, 'in', '(${excludingCodes!.join(',')})');
    }

    final data = await query;
    final list = data.map(SupabaseWallet.from).whereType<Wallet>().toList();
    return DataPage(content: list);
  }

  @override
  Future<void> deleteWallet({
    required String code,
  }) async {
    await config.supabase.from(walletTable).delete().match({codeField: code});
  }

  Future<bool> _walletExistsByCode(String code) async {
    final count = await config.supabase.from(walletTable).select(idField).eq(codeField, code).count(CountOption.exact);
    return count.count > 0;
  }

  @override
  Future<Wallet> fetchWalletByCode(String code) async {
    final walletData = await config.supabase.from(walletTable).select().eq(codeField, code);
    final wallet = SupabaseWallet.from(walletData);
    if (wallet != null) {
      return wallet;
    }
    throw ValidationError({
      'wallet': WalletError.invalidWallet,
    });
  }

  @override
  Future<Wallet?> fetchWalletById(int id) async {
    final walletData = await config.supabase.from(walletTable).select().eq(idField, id);
    return SupabaseWallet.from(walletData);
  }

  @override
  Future<Map<Wallet, double>> walletsBalance({
    required Period period,
    bool showZeroBalance = false,
  }) async {
    final transactions = await DI().get<TransactionService>().listTransactions(
          period: period,
          dateTimeSort: Sort.desc,
        );
    final map = <Wallet, double>{};
    for (var transaction in transactions) {
      map[transaction.wallet] = (map[transaction.wallet] ?? 0) + transaction.signedAmount;
    }
    if (showZeroBalance) {
      final includedWallets = map.keys.map((wallet) {
        return wallet.code;
      });
      final zeroWallets = await listWallets(
        excludingCodes: includedWallets.toList(),
      );
      map.addEntries(zeroWallets.content.map((wallet) {
        return MapEntry(wallet, 0);
      }));
    }
    return map;
  }

  @override
  Future<void> updateWalletBalance({
    required String code,
    required Period period,
  }) {
    // TODO: implement updateWalletBalance
    return Future.value();
  }
}

class SupabaseWallet implements Wallet {
  final int id;

  SupabaseWallet({
    this.id = 0,
    required this.code,
    required this.walletType,
    required this.name,
  });

  @override
  String code;

  @override
  WalletType walletType;

  @override
  String name;

  Map<String, Object> toMap(AppUser user) {
    return <String, Object>{
      userIdField: user.id,
      codeField: code,
      walletTypeField: walletType.name,
      nameField: name,
    };
  }

  static SupabaseWallet? from(dynamic raw) {
    dynamic rawData;
    if (raw is List && raw.isNotEmpty) {
      rawData = raw[0];
    } else {
      rawData = raw;
    }
    if (rawData is Map<String, dynamic>) {
      final id = rawData[idField] as int?;
      final code = rawData[codeField] as String?;
      final walletType = WalletType.tryParse(rawData[walletTypeField] as String?);
      final name = rawData[nameField] as String?;
      if (id != null && code != null && walletType != null && name != null) {
        return SupabaseWallet(id: id, code: code, walletType: walletType, name: name);
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is SupabaseWallet && runtimeType == other.runtimeType && code == other.code;
  }

  @override
  int get hashCode {
    return code.hashCode;
  }
}
