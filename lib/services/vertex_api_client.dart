import 'api_client.dart';

/// Mirrors `src/services/vertexApiClient.js`.
class VertexApiClient {
  VertexApiClient({ApiClient? client}) : _client = client ?? apiClient;

  final ApiClient _client;

  String get baseUrl => _client.baseUrl;
  bool get isConfigured => baseUrl.isNotEmpty;

  Future<String> chat(
    String message, {
    double? temperature,
    int? maxOutputTokens,
  }) async {
    final body = <String, dynamic>{'message': message};
    if (temperature != null) body['temperature'] = temperature;
    if (maxOutputTokens != null) body['maxOutputTokens'] = maxOutputTokens;

    final data = await _client.fetchJson('/chat', body: body);
    final reply = data['reply'];
    if (reply is! String) {
      throw Exception('Vertex /chat: response missing reply');
    }
    return reply;
  }

  Future<String> reflection(List<Map<String, dynamic>> conversation) async {
    final data = await _client.fetchJson(
      '/reflection',
      body: {'conversation': conversation},
    );
    final reflection = data['reflection'];
    if (reflection is! String) {
      throw Exception('Vertex /reflection: response missing reflection');
    }
    return reflection;
  }

  Future<String> summary(String text) async {
    final data = await _client.fetchJson('/summary', body: {'text': text});
    final summary = data['summary'];
    if (summary is! String) {
      throw Exception('Vertex /summary: response missing summary');
    }
    return summary;
  }

  Future<String> analyzePattern(dynamic data) async {
    final res = await _client.fetchJson('/analyze-pattern', body: {'data': data});
    final result = res['result'];
    if (result is! String) {
      throw Exception('Vertex /analyze-pattern: response missing result');
    }
    return result;
  }

  Future<String> generateContent({
    required String prompt,
    double temperature = 0.65,
    int maxOutputTokens = 2048,
  }) async {
    final data = await _client.fetchJson(
      '/generateContent',
      body: {
        'prompt': prompt,
        'temperature': temperature,
        'maxOutputTokens': maxOutputTokens,
      },
    );
    if (data['candidates'] != null) {
      final parts = data['candidates'][0]?['content']?['parts'] as List?;
      if (parts != null) {
        return parts.map((p) => (p as Map)['text'] ?? '').join();
      }
    }
    if (data['text'] is String) return data['text'] as String;
    throw Exception('Unexpected /generateContent response');
  }
}

final vertexApiClient = VertexApiClient();
