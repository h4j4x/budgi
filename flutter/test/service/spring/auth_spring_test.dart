import 'dart:convert';

import 'package:budgi/service/storage.dart';
import 'package:http/http.dart' as http;
import 'package:budgi/service/spring/auth_spring.dart';
import 'package:budgi/service/spring/config.dart';
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([MockSpec<StorageService>()])
import 'auth_spring_tests.mocks.dart';

void main() {
  const baseUrl = 'http://api/v1';
  final storageService = MockStorageService();

  test('.signIn()', () async {
    reset(storageService);

    const token = 'auth-token';
    final expiresAt = DateTime.now().add(const Duration(days: 1));
    final tokenMap = <String, Object>{
      'token': token,
      'tokenType': 'Bearer',
      'expiresAt': expiresAt.toString(),
    };
    final tokenJson = jsonEncode(tokenMap);

    var client = MockClient((request) async {
      return http.Response(
        tokenJson,
        200,
        request: request,
        headers: {'content-type': 'application/json'},
      );
    });

    final config = SpringConfig(url: baseUrl);
    final service = AuthSpringService(
      storageService: storageService,
      config: config,
      httpClient: client,
    );

    try {
      final success = await service.signIn(
        email: 'email',
        password: 'password',
      );
      expect(success, isTrue);
    } catch (e) {
      fail(e.toString());
    }

    verify(storageService.writeString(authTokenKey, tokenJson));
  });
}
