import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../model/token.dart';

class ApiHttpClient {
  final String baseUrl;
  final http.Client httpClient;

  ApiHttpClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  Future<T> jsonPost<T>({
    required String path,
    Map<String, String>? data,
    AppToken? appToken,
  }) async {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
    };
    if (appToken != null) {
      headers[HttpHeaders.authorizationHeader] = appToken.tokenHeader;
    }
    final response = await httpClient.post(
      Uri.parse('$baseUrl$path'),
      body: data != null ? jsonEncode(data) : null,
      headers: headers,
    );
    if (_is2xxStatus(response.statusCode)) {
      return jsonDecode(response.body) as T;
    }
    throw HttpError(
      statusCode: response.statusCode,
      reasonPhrase: response.reasonPhrase,
    );
  }

  bool _is2xxStatus(int code) {
    return code >= 200 && code < 300;
  }
}

class HttpError extends Error {
  final int statusCode;
  final String? reasonPhrase;

  HttpError({
    required this.statusCode,
    required this.reasonPhrase,
  });
}
