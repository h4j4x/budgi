import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../app/icon.dart';
import '../../model/domain/user.dart';
import '../../model/error/http.dart';
import '../../model/fields.dart';
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
const _emailField = 'email';
const _fetchedAtField = 'fetchedAt';

class AuthSpringService extends AuthService {
  final StorageService storageService;
  final ApiHttpClient _httpClient;
  final StreamController<bool> _streamController;
  final http.Client? httpClient;

  AppToken? _token;
  _User? _user;

  AuthSpringService({
    required this.storageService,
    required SpringConfig config,
    this.httpClient,
  })  : _httpClient = ApiHttpClient(
            httpClient: httpClient, baseUrl: '${config.url}/auth'),
        _streamController = BehaviorSubject<bool>();

  Future<void> initialize() async {
    final json = await storageService.readString(authTokenKey);
    if (json != null) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      _token = _Token.parseMap(map);
      if (_token?.isValid ?? false) {
        await _updateUser(false);
      }
    }
    debugPrint('Auth token $_token');
    if (_user == null) {
      await _signOut();
    }
    _streamController.add(_token?.isValid ?? false);
  }

  @override
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.jsonPost<Map<String, dynamic>>(
        authService: this,
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
    } on SocketException catch (_) {
      throw NoServerError();
    } on HttpError catch (_) {
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
    if (_token?.isValid ?? false) {
      return _user;
    }
    return null;
  }

  @override
  Future<AppUser> fetchUser<T>({required T errorIfMissing}) async {
    if (_token?.isValid ?? false) {
      await _updateUser();
    }
    return super.fetchUser(errorIfMissing: errorIfMissing);
  }

  @override
  AppToken? token() {
    return _token;
  }

  @override
  Future<void> signOut() async {
    await _signOut();
    _streamController.add(false);
    return Future.value();
  }

  Future<void> _signOut() async {
    _token = null;
    return storageService.writeString(authTokenKey, null);
  }

  Future<void> _updateUser([bool signOutIf401 = true]) async {
    if (_user?.fetchedLessThanHoursAgo(6) ?? false) {
      return Future.value();
    }
    try {
      final response = await _httpClient.jsonGet<Map<String, dynamic>>(
        authService: this,
        path: '/me',
      );
      _user = _User.parseMap(response);
      await storageService.writeString(authTokenKey, _user!.asJson);
    } on HttpError catch (e) {
      if (e.statusCode == 401 && signOutIf401) {
        await signOut();
      }
    } catch (e) {
      debugPrint('Unexpected error $e');
    }
  }
}

class _User implements AppUser {
  @override
  final String name;

  @override
  final String email;

  final DateTime fetchedAt;

  _User({
    required this.name,
    required this.email,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

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

  static _User? parseMap(Map<String, dynamic> map) {
    final name = map[nameField] as String?;
    final email = map[_emailField] as String?;
    if (name != null && email != null) {
      final fetchedAt = DateTime.tryParse(map[_fetchedAtField] ?? '');
      return _User(name: name, email: email, fetchedAt: fetchedAt);
    }
    return null;
  }

  String get asJson {
    return jsonEncode({
      nameField: name,
      _emailField: email,
      _fetchedAtField: fetchedAt.toString(),
    });
  }

  bool fetchedLessThanHoursAgo(int hours) {
    final fetchedHoursAgo = fetchedAt.difference(DateTime.now()).inHours;
    return fetchedHoursAgo < hours;
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

  @override
  String toString() {
    return 'AppToken{expiresAt: $expiresAt}';
  }
}
