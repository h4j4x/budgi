import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../../app/icon.dart';
import '../../model/domain/user.dart';
import '../../model/token.dart';
import '../../util/datetime.dart';
import '../auth.dart';
import '../storage.dart';
import 'config.dart';
import 'http_client.dart';

const authTokenKey = 'app_auth_token';
const _tokenField = 'token';
const _tokenTypeField = 'tokenType';
const _expiresAtField = 'expiresAt';

class AuthSpringService extends AuthService {
  final StorageService storageService;
  final ApiHttpClient _httpClient;
  final StreamController<bool> _streamController;
  final http.Client? httpClient;

  AppToken? _token;

  AuthSpringService({
    required this.storageService,
    required SpringConfig config,
    this.httpClient,
  })  : _httpClient = ApiHttpClient(
            httpClient: httpClient, baseUrl: '${config.url}/auth'),
        _streamController = StreamController<bool>();

  Future<void> initialize() async {
    final json = await storageService.readString(authTokenKey);
    if (json != null) {
      final map = jsonDecode(json) as Map<String, String>;
      _token = _Token.parseMap(map);
    }
  }

  @override
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.jsonPost<Map<String, dynamic>>(
        path: '/signin',
        data: {
          'email': email,
          'password': password,
        },
      );
      _token = _Token.parseMap(response);
      await storageService.writeString(
          authTokenKey, _token!.isValid ? _token!.asJson : null);
      _streamController.add(_token!.isValid);
      return _token!.isValid;
    } on http.ClientException catch (_) {
      throw SignInError();
    } catch (e) {
      debugPrint('Unexpected error $e');
      throw SignInError();
    }
  }

  @override
  Future<bool> signInWithGithub() {
    return Future.value(false);
  }

  @override
  Stream<bool> authenticatedStream() {
    return _streamController.stream;
  }

  @override
  AppUser? user() {
    // TODO: recover from JSON
    return null;
  }

  @override
  AppToken? token() {
    return _token;
  }

  @override
  Future<void> signOut() async {
    _token = null;
    await storageService.writeString(authTokenKey, null);
    _streamController.add(false);
    return Future.value();
  }
}

class _User implements AppUser {
  @override
  final String name;

  @override
  final String email;

  _User({
    required this.name,
    required this.email,
  });

  @override
  String get id {
    return email;
  }

  @override
  String? get avatarUrl {
    return null;
  }

  @override
  String get username {
    return email.split('@').first;
  }

  @override
  Widget icon({double? size, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(child: AppIcon.user(size: size, color: color)),
    );
  }

  @override
  String get usernameOrEmail {
    return username;
  }
}

class _Token implements AppToken {
  final String token;
  final String tokenType;
  final DateTime expiresAt;

  _Token({
    required this.token,
    required this.tokenType,
    required this.expiresAt,
  });

  static _Token parseMap(Map<String, dynamic> map) {
    final token = map[_tokenField] as String?;
    final tokenType = map[_tokenTypeField] as String?;
    final expiresAt = DateTime.tryParse(map[_expiresAtField] as String? ?? '');
    if (token != null && tokenType != null && expiresAt != null) {
      return _Token(token: token, tokenType: tokenType, expiresAt: expiresAt);
    }
    return _Token(
        token: '-', tokenType: '-', expiresAt: DateTime.now().atStartOfDay());
  }

  @override
  bool get isValid {
    return expiresAt.isAfter(DateTime.now());
  }

  @override
  String get asJson {
    return jsonEncode({
      _tokenField: token,
      _tokenTypeField: tokenType,
      _expiresAtField: expiresAt.toString(),
    });
  }

  @override
  String get tokenHeader {
    return '$tokenType $token';
  }
}
