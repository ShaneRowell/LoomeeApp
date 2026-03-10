import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import '../config/environment.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized'])
      : super(message, statusCode: 401);
}

class ApiClient {
  final StorageService _storage;
  VoidCallback? onUnauthorized;

  ApiClient(this._storage);

  String get _baseUrl => Environment.apiBaseUrl;

  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (withAuth) {
      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String path,
      {Map<String, String>? queryParams, bool withAuth = true}) async {
    try {
      final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    }
  }

  Future<dynamic> post(String path,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final headers = await _getHeaders();
      final response = await http.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final headers = await _getHeaders();
      final response = await http.delete(uri, headers: headers);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    }
  }

  Future<dynamic> multipartPost(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, String>? fields,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final request = http.MultipartRequest('POST', uri);

      final token = await _storage.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final ext = p.extension(filePath).toLowerCase();
      MediaType? contentType;
      if (ext == '.jpg' || ext == '.jpeg') {
        contentType = MediaType('image', 'jpeg');
      } else if (ext == '.png') {
        contentType = MediaType('image', 'png');
      }

      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        filePath,
        contentType: contentType,
      ));

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);

    if (response.statusCode == 401) {
      onUnauthorized?.call();
      throw UnauthorizedException(body['message'] ?? 'Unauthorized');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      body['message'] ?? 'Something went wrong',
      statusCode: response.statusCode,
    );
  }
}

typedef VoidCallback = void Function();
