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
    Set<String>? includingCodes,
    Set<String>? excludingCodes,
    int? page,
    int? pageSize,
  }) {
    final data = <String, String>{};
    if (includingCodes?.isNotEmpty ?? false) {
      data[includingCodesField] = includingCodes!.join(';');
    }
    if (excludingCodes?.isNotEmpty ?? false) {
      data[excludingCodesField] = excludingCodes!.join(';');
    }
    try {
      return _httpClient.jsonGetPage<Wallet>(
        authService: authService,
        page: page,
        pageSize: pageSize,
        data: data.isNotEmpty ? data : null,
        mapper: _SpringWallet.from,
      );
    } on SocketException catch (_) {
      throw NoServerError();
    }
  }

  @override
  Future<Wallet> saveWallet({
    String? code,
    required WalletType walletType,
    required String name,
  }) async {
    final wallet = _SpringWallet()
      ..code = code ?? ''
      ..name = name
      ..walletType = walletType;
    final errors = walletValidator.validate(wallet);
    if (errors.isNotEmpty) {
      throw ValidationError(errors);
    }
    try {
      Map<String, dynamic> response;
      if (code?.isNotEmpty ?? false) {
        response = await _httpClient.jsonPut<Map<String, dynamic>>(
          authService: authService,
          path: '/$code',
          data: wallet.toMap(),
        );
      } else {
        response = await _httpClient.jsonPost<Map<String, dynamic>>(
          authService: authService,
          data: wallet.toMap(),
        );
      }
      return _SpringWallet.from(response)!;
    } on SocketException catch (_) {
      throw NoServerError();
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
  Future<void> deleteWallets({required Set<String> codes}) async {
    if (codes.isEmpty) {
      return Future.value();
    }
    try {
      await _httpClient.delete(
          authService: authService, path: '/batch?codes=${codes.join(',')}');
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
  Future<Map<Wallet, double>> walletsBalance(
      {required Period period, bool showZeroBalance = false}) {
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
