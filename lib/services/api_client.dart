import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Mirrors `src/services/apiClient.js`.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get baseUrl => AppConfig.backendUrl;

  Future<Map<String, dynamic>> fetchJson(
    String path, {
    String method = 'POST',
    Map<String, dynamic>? body,
  }) async {
    final finalPath = path.startsWith('/') ? path : '/$path';
    final url = Uri.parse('$baseUrl$finalPath');

    http.Response res;
    try {
      final request = http.Request(method, url)
        ..headers['Content-Type'] = 'application/json';
      if (body != null) {
        request.body = jsonEncode(body);
      }
      res = await _client.send(request).then(http.Response.fromStream);
    } catch (e) {
      throw Exception('Network error calling backend ($url): $e');
    }

    final text = res.body;
    Map<String, dynamic> data = {};
    if (text.isNotEmpty) {
      try {
        data = jsonDecode(text) as Map<String, dynamic>;
      } catch (_) {
        throw Exception(
          'Backend returned non-JSON (${res.statusCode}) from $url: '
          '${text.length > 240 ? text.substring(0, 240) : text}',
        );
      }
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = data['error'] ?? data['message'] ?? text;
      throw Exception(msg is String ? msg : msg.toString());
    }

    return data;
  }
}

final apiClient = ApiClient();
