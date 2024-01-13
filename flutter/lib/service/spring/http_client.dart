import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../model/data_page.dart';
import '../../model/token.dart';
import '../auth.dart';

class ApiHttpClient {
  final String baseUrl;
  final http.Client httpClient;

  ApiHttpClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  Future<T> jsonGet<T>({
    required AuthService authService,
    String path = '',
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response =
        await httpClient.get(uri, headers: _headers(authService.token()));
    if (_is2xxStatus(response.statusCode)) {
      return jsonDecode(response.body) as T;
    }
    await _check401Status(authService, response.statusCode);
    throw HttpError(
      statusCode: response.statusCode,
      reasonPhrase: response.reasonPhrase,
    );
  }

  Future<DataPage<T>> jsonGetPage<T>({
    required AuthService authService,
    required DataMapper mapper,
    String path = '',
    int? page,
    int? pageSize,
    Map<String, String>? data,
  }) async {
    final uri = _queryUri('$baseUrl$path', data, page, pageSize);
    final response =
        await httpClient.get(uri, headers: _headers(authService.token()));
    if (_is2xxStatus(response.statusCode)) {
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      return _from<T>(map, mapper: mapper)!;
    }
    await _check401Status(authService, response.statusCode);
    throw HttpError(
      statusCode: response.statusCode,
      reasonPhrase: response.reasonPhrase,
    );
  }

  Future<T> jsonPost<T>({
    required AuthService authService,
    String path = '',
    Map<String, Object>? data,
  }) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl$path'),
      body: data != null ? jsonEncode(data) : null,
      headers: _headers(authService.token()),
    );
    if (_is2xxStatus(response.statusCode)) {
      return jsonDecode(response.body) as T;
    }
    await _check401Status(authService, response.statusCode);
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

  static DataPage<T>? _from<T>(Map<String, dynamic> map,
      {required DataMapper mapper}) {
    final content = map['content'] as List<dynamic>?;
    final pageable = (map['pageable'] as Map<String, dynamic>?) ?? {};
    final pageNumber = pageable['pageNumber'] as int?;
    final pageSize = pageable['pageSize'] as int?;
    final totalElements = map['totalElements'] as int?;
    final totalPages = map['totalPages'] as int?;
    if (content != null &&
        pageNumber != null &&
        pageSize != null &&
        totalElements != null &&
        totalPages != null) {
      final list = content.map(mapper).whereType<T>().toList();
      return DataPage<T>(
        content: list,
        pageNumber: pageNumber,
        pageSize: pageSize,
        totalElements: totalElements,
        totalPages: totalPages,
      );
    }
    return null;
  }

  Uri _queryUri(String url, Map<String, String>? data,
      [int? page, int? pageSize]) {
    final params = <String, String>{};
    if (data?.isNotEmpty ?? false) {
      params.addAll(data!);
    }
    if (page != null && page >= 0) {
      params['page'] = page.toString();
    }
    if (pageSize != null && pageSize > 0) {
      params['pageSize'] = pageSize.toString();
    }
    final uri = Uri.parse(url);
    if (params.isNotEmpty) {
      return Uri(
          scheme: uri.scheme,
          host: uri.host,
          port: uri.port,
          path: uri.path,
          queryParameters: params);
    }
    return uri;
  }

  Future<void> _check401Status(AuthService authService, int statusCode) async {
    if (statusCode == 401) {
      await authService.signOut();
    }
  }
}

class HttpError extends Error {
  final int statusCode;
  final String? reasonPhrase;

  HttpError({
    required this.statusCode,
    required this.reasonPhrase,
  });

  @override
  String toString() {
    return 'HttpError{statusCode: $statusCode, reasonPhrase: $reasonPhrase}';
  }
}

typedef DataMapper<T> = T? Function(dynamic);
