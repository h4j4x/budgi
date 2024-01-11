import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../model/data_page.dart';
import '../../model/token.dart';

class ApiHttpClient {
  final String baseUrl;
  final http.Client httpClient;

  ApiHttpClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  Future<DataPage<T>> jsonGetPage<T>({
    required DataMapper mapper,
    String path = '',
    Map<String, String>? data,
    AppToken? appToken,
  }) async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(appToken),
    );
    if (_is2xxStatus(response.statusCode)) {
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      return _from<T>(map, mapper: mapper)!;
    }
    throw HttpError(
      statusCode: response.statusCode,
      reasonPhrase: response.reasonPhrase,
    );
  }

  Future<T> jsonPost<T>({
    String path = '',
    Map<String, Object>? data,
    AppToken? appToken,
  }) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl$path'),
      body: data != null ? jsonEncode(data) : null,
      headers: _headers(appToken),
    );
    if (_is2xxStatus(response.statusCode)) {
      return jsonDecode(response.body) as T;
    }
    throw HttpError(
      statusCode: response.statusCode,
      reasonPhrase: response.reasonPhrase,
    );
  }

  Map<String, String> _headers(AppToken? appToken) {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
    };
    if (appToken != null) {
      headers[HttpHeaders.authorizationHeader] = appToken.tokenHeader;
    }
    return headers;
  }

  bool _is2xxStatus(int code) {
    return code >= 200 && code < 300;
  }

  static DataPage<T>? _from<T>(Map<String, dynamic> map, {required DataMapper mapper}) {
    final content = map['content'] as List<Map<String, dynamic>>?;
    final totalElements = map['totalElements'] as int?;
    final pageable = (map['pageable'] as Map<String, dynamic>?) ?? {};
    final pageNumber = pageable['pageNumber'] as int?;
    final pageSize = pageable['pageSize'] as int?;
    if (content != null && totalElements != null && pageNumber != null && pageSize != null) {
      final list = content.map((e) => mapper).whereType<T>().toList();
      return DataPage<T>(content: list, pageNumber: pageNumber, pageSize: pageSize, totalElements: totalElements);
    }
    return null;
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

typedef DataMapper<T> = T? Function(Map<String, dynamic>);
