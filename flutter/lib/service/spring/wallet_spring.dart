import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../model/data_page.dart';
import '../../model/domain/wallet.dart';
import '../../model/error/http.dart';
import '../../model/error/validation.dart';
import '../../model/error/wallet.dart';
import '../../model/fields.dart';
import '../../model/period.dart';
import '../auth.dart';
import '../validator.dart';
import '../wallet.dart';
import 'config.dart';
import 'http_client.dart';

class WalletSpringService implements WalletService {
  final AuthService authService;
  final Validator<Wallet, WalletError> walletValidator;
  final ApiHttpClient _httpClient;

  WalletSpringService({
    required this.authService,
    required this.walletValidator,
    required SpringConfig config,
  }) : _httpClient = ApiHttpClient(baseUrl: '${config.url}/wallet');

  @override
  Future<DataPage<Wallet>> listWallets({
    List<String>? excludingCodes,
    int? page,
    int? pageSize,
  }) async {
    try {
      final v = await _httpClient.jsonGetPage<Wallet>(
        authService: authService,
        page: page,
        pageSize: pageSize,
        mapper: _SpringWallet.from,
      );
      return v;
    } on SocketException catch (_) {
      throw NoServerError();
    }
  }

  @override
  Future<Wallet> saveWallet({String? code, required WalletType walletType, required String name}) async {
    final wallet = _SpringWallet()
      ..code = code ?? ''
      ..name = name
      ..walletType = walletType;
    final errors = walletValidator.validate(wallet);
    if (errors.isNotEmpty) {
      throw ValidationError(errors);
    }
    try {
      final response = await _httpClient.jsonPost<Map<String, dynamic>>(
        authService: authService,
        path: code != null ? '/$code' : '',
        data: wallet.toMap(),
      );
      return _SpringWallet.from(response)!;
    } on SocketException catch (_) {
      throw NoServerError();
    } catch (e) {
      debugPrint('Unexpected error $e');
      throw ValidationError({
        'wallet': WalletError.invalidWallet,
      });
    }
  }

  @override
  Future<void> deleteWallet({required String code}) async {
    try {
      await _httpClient.delete(authService: authService, path: '/$code');
    } on SocketException catch (_) {
      throw NoServerError();
    } catch (e) {
      debugPrint('Unexpected error $e');
      throw ValidationError({
        'wallet': WalletError.invalidWallet,
      });
    }
  }

  @override
  Future<void> updateWalletBalance({required String code, required Period period}) {
    // TODO: implement updateWalletBalance
    return Future.value();
  }

  @override
  Future<Map<Wallet, double>> walletsBalance({required Period period, bool showZeroBalance = false}) {
    // TODO: implement walletsBalance
    return Future.value({});
  }
}

class _SpringWallet implements Wallet {
  @override
  String code = '';

  @override
  WalletType walletType = WalletType.cash;

  @override
  String name = '';

  Map<String, Object> toMap() {
    return <String, Object>{
      codeField: code,
      walletTypeField: walletType.name,
      nameField: name,
    };
  }

  static _SpringWallet? from(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final code = raw[codeField] as String?;
      final walletType = WalletType.tryParse(raw[walletTypeField]);
      final name = raw[nameField] as String?;
      if (code != null && walletType != null && name != null) {
        return _SpringWallet()
          ..code = code
          ..name = name
          ..walletType = walletType;
      }
    }
    return null;
  }
}
