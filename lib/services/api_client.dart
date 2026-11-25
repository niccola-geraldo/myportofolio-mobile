import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int? statusCode;
  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, String baseUrl = apiBaseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), '');

  static const _projectsPath = '/api/v1/projects/';
  static const _timeout = Duration(seconds: 15);
  static const _acceptJson = {'Accept': 'application/json'};

  final http.Client _client;
  final String _baseUrl;

  Future<List<Project>> getProjects() async {
    final response = await _request(
      () => _client.get(_uri(_projectsPath), headers: _acceptJson),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return data
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _post(
      _projectsPath,
      token: token,
      data: project.toJson(),
    );
    return Project.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _post(
      '/api/v1/auth/token/',
      data: {'username': username, 'password': password},
    );
    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final token = data['token'];
    if (token is! String || token.isEmpty) {
      throw const ApiException(null, 'Server tidak mengirim token login.');
    }
    return token;
  }

  Future<void> logout({required String token}) async {
    await _post('/api/v1/auth/logout/', token: token);
  }

  void close() => _client.close();

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<http.Response> _post(
    String path, {
    String? token,
    Map<String, dynamic>? data,
  }) => _request(
    () => _client.post(
      _uri(path),
      headers: {
        ..._acceptJson,
        if (data != null) 'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Token $token',
      },
      body: data == null ? null : jsonEncode(data),
    ),
  );

  Future<http.Response> _request(Future<http.Response> Function() send) async {
    try {
      final response = await send().timeout(_timeout);
      final status = response.statusCode;
      if (status >= 200 && status < 300) return response;
      throw ApiException(status, 'Permintaan gagal (HTTP $status).');
    } on http.ClientException {
      throw const ApiException(null, 'Tidak dapat terhubung ke server.');
    } on TimeoutException {
      throw const ApiException(null, 'Server terlalu lama merespons.');
    }
  }
}
