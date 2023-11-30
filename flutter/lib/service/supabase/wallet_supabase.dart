import 'package:supabase_flutter/supabase_flutter.dart';

import '../../di.dart';
import '../../model/domain/user.dart';
import '../../model/domain/wallet.dart';
import '../../model/error/validation.dart';
import '../../model/error/wallet.dart';
import '../../model/fields.dart';
import '../../model/period.dart';
import '../../util/string.dart';
import '../auth.dart';
import '../validator.dart';
import '../wallet.dart';
import 'supabase.dart';

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
    final user = _fetchUser();

    final walletCode = code ?? randomString(6);
    final wallet =
        _Wallet(code: walletCode, walletType: walletType, name: name);
    final errors = walletValidator?.validate(wallet);
    if (errors?.isNotEmpty ?? false) {
      throw ValidationError<WalletError>(errors!);
    }

    final walletExists = await _walletExistsByCode(walletCode);
    if (walletExists) {
      await config.supabase
          .from(walletTable)
          .update(wallet.toMap(user))
          .match({codeField: walletCode});
    } else {
      await config.supabase.from(walletTable).insert(wallet.toMap(user));
    }
    return wallet;
  }

  @override
  Future<List<Wallet>> listWallets() async {
    final user = DI().get<AuthService>().user();
    if (user == null) {
      return [];
    }

    final data = await config.supabase
        .from(walletTable)
        .select()
        .eq(userIdField, user.id);
    if (data is List) {
      return data.map(_Wallet.from).whereType<Wallet>().toList();
    }
    return [];
  }

  @override
  Future<void> deleteWallet({
    required String code,
  }) async {
    await config.supabase.from(walletTable).delete().match({codeField: code});
  }

  Future<bool> _walletExistsByCode(String code) async {
    final count = await config.supabase
        .from(walletTable)
        .select(
          idField,
          const FetchOptions(
            count: CountOption.exact,
          ),
        )
        .eq(codeField, code);
    return count.count != null && count.count! > 0;
  }

  @override
  Future<Wallet> fetchWalletByCode(String code) async {
    final walletData =
        await config.supabase.from(walletTable).select().eq(codeField, code);
    final wallet = _Wallet.from(walletData);
    if (wallet != null) {
      return wallet;
    }
    throw ValidationError({
      'wallet': WalletError.invalidWallet,
    });
  }

  @override
  Future<Wallet?> fetchWalletById(int id) async {
    final walletData =
        await config.supabase.from(walletTable).select().eq(idField, id);
    return _Wallet.from(walletData);
  }

  AppUser _fetchUser() {
    final user = DI().get<AuthService>().user();
    if (user != null) {
      return user;
    }
    throw ValidationError<WalletError>({
      'user': WalletError.invalidUser,
    });
  }

  @override
  Future<Map<Wallet, double>> walletsBalance(
      {required Period period, bool showZeroBalance = false}) {
    // TODO: implement walletsBalance
    return Future.value({});
  }
}

class _Wallet implements Wallet {
  final int id;

  _Wallet({
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

  static _Wallet? from(dynamic raw) {
    dynamic rawData;
    if (raw is List && raw.isNotEmpty) {
      rawData = raw[0];
    } else {
      rawData = raw;
    }
    if (rawData is Map<String, dynamic>) {
      final id = rawData[idField] as int?;
      final code = rawData[codeField] as String?;
      final walletType =
          WalletType.tryParse(rawData[walletTypeField] as String?);
      final name = rawData[nameField] as String?;
      if (id != null && code != null && walletType != null && name != null) {
        return _Wallet(id: id, code: code, walletType: walletType, name: name);
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _Wallet &&
        runtimeType == other.runtimeType &&
        code == other.code;
  }

  @override
  int get hashCode {
    return code.hashCode;
  }
}
