import 'dart:convert';

import '../models/chat_message.dart';
import 'vertex_api_client.dart';

/// Mood scoring from chat — port of `emotionalAnalysisService.js` via Vertex.
class EmotionalAnalysisService {
  EmotionalAnalysisService({VertexApiClient? vertex})
      : _vertex = vertex ?? vertexApiClient;

  final VertexApiClient _vertex;

  Future<MoodScores> analyzeMessages(List<ChatMessage> messages) async {
    final lines = messages
        .where((m) => m.text.trim().isNotEmpty && !m.isWhisperSession)
        .map((m) => '${m.sender == 'user' ? 'User' : 'Detea'}: ${m.text}')
        .join('\n');
    if (lines.isEmpty) return MoodScores.defaults();

    if (!_vertex.isConfigured) return MoodScores.defaults();

    try {
      final prompt = '''
Analyze the emotional state from this conversation and provide numerical scores (0-100) for:
- happiness (how positive/joyful)
- energy (how energetic/motivated)
- anxiety (how worried/anxious)
- stress (how stressed/pressured)

Conversation:
$lines

Respond ONLY with a JSON object in this exact format:
{"happiness": <number>, "energy": <number>, "anxiety": <number>, "stress": <number>}
''';
      final reply = await _vertex.chat(prompt, temperature: 0.3, maxOutputTokens: 300);
      final match = RegExp(r'\{[\s\S]*\}').firstMatch(reply);
      if (match == null) return MoodScores.defaults();
      final json = jsonDecode(match.group(0)!) as Map<String, dynamic>;
      return MoodScores(
        happiness: _num(json['happiness']),
        energy: _num(json['energy']),
        anxiety: _num(json['anxiety']),
        stress: _num(json['stress']),
      );
    } catch (_) {
      return MoodScores.defaults();
    }
  }

  double _num(dynamic v) {
    if (v is num) return v.toDouble().clamp(0, 100);
    return 50;
  }
}

class MoodScores {
  const MoodScores({
    required this.happiness,
    required this.energy,
    required this.anxiety,
    required this.stress,
  });

  final double happiness;
  final double energy;
  final double anxiety;
  final double stress;

  factory MoodScores.defaults() => const MoodScores(
        happiness: 50,
        energy: 50,
        anxiety: 30,
        stress: 30,
      );
}

final emotionalAnalysisService = EmotionalAnalysisService();
