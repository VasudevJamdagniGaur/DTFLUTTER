import 'dart:typed_data';

import '../core/utils/date_utils.dart';
import '../models/chat_message.dart';
import 'auth_service.dart';
import 'emotional_analysis_service.dart';
import 'firestore_service.dart';
import 'reflection_service.dart';
import 'vertex_api_client.dart';

/// AI chat companion — port of `chatService.js` (Vertex backend, days/ messages).
class ChatService {
  ChatService({
    VertexApiClient? vertex,
    FirestoreService? firestore,
    AuthService? auth,
    ReflectionService? reflection,
    EmotionalAnalysisService? emotional,
  })  : _vertex = vertex ?? vertexApiClient,
        _firestore = firestore ?? firestoreService,
        _auth = auth ?? authService,
        _reflection = reflection ?? reflectionService,
        _emotional = emotional ?? emotionalAnalysisService;

  final VertexApiClient _vertex;
  final FirestoreService _firestore;
  final AuthService _auth;
  final ReflectionService _reflection;
  final EmotionalAnalysisService _emotional;

  static const _companionPrompt = '''
You are Detea, a warm, thoughtful emotional wellness companion. Listen deeply,
validate feelings, ask gentle follow-up questions, and help users reflect on
their day. Keep responses concise (2-4 sentences unless they need more).
Never give medical diagnoses. Be supportive, human, and non-judgmental.
''';

  static const _whisperPrompt = '''
You are Detea in Whisper Session mode — a private, confidential space.
The user may share sensitive thoughts. Respond with extra care, no judgment,
and gentle validation. Do not reference saving or sharing this conversation.
Keep responses concise and human.
''';

  Future<String> sendMessage({
    required String userText,
    required List<ChatMessage> history,
    String? dateId,
    bool isWhisperSession = false,
    Uint8List? imageBytes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in');

    final id = dateId ?? DeiteDateUtils.getDateId();
    String? imageUrl;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      imageUrl = await _firestore.uploadPostImageBytes(user.uid, imageBytes);
    }

    final userTextFinal = imageBytes != null && userText.isEmpty
        ? '[Shared a photo]'
        : userText;

    await _firestore.saveChatMessageNew(
      user.uid,
      id,
      sender: 'user',
      text: userTextFinal,
      isWhisperSession: isWhisperSession,
      imageUrl: imageUrl,
    );

    final system = isWhisperSession ? _whisperPrompt : _companionPrompt;
    final conversation = history
        .where((m) => !m.isWhisperSession || isWhisperSession)
        .map((m) => '${m.sender == 'user' ? 'User' : 'Detea'}: ${m.text}')
        .join('\n');

    final prompt = '''
$system

Conversation so far:
$conversation
${imageUrl != null ? 'The user also shared a photo with this message.\n' : ''}User: $userTextFinal
Detea:''';

    if (!_vertex.isConfigured) {
      throw Exception(
        'AI backend not configured. Set BACKEND_URL dart-define.',
      );
    }

    final reply = await _vertex.chat(prompt.trim());
    await _firestore.saveChatMessageNew(
      user.uid,
      id,
      sender: 'ai',
      text: reply,
      isWhisperSession: isWhisperSession,
    );
    return reply;
  }

  Future<List<ChatMessage>> loadMessages(
    String dateId, {
    bool whisperOnly = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];
    final all = await _firestore.getChatMessagesNew(user.uid, dateId);
    if (whisperOnly) {
      return all.where((m) => m.isWhisperSession).toList();
    }
    return all;
  }

  Stream<List<ChatMessage>> watchMessages(String dateId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _firestore.watchChatMessagesNew(user.uid, dateId);
  }

  Future<void> finalizeSession({
    required String dateId,
    required List<ChatMessage> messages,
    bool isWhisperSession = false,
  }) async {
    if (isWhisperSession) return;
    final user = _auth.currentUser;
    if (user == null) return;

    final nonWhisper =
        messages.where((m) => !m.isWhisperSession && m.text.isNotEmpty).toList();
    if (nonWhisper.length < 2) return;

    try {
      final summary = await _reflection.generateReflection(nonWhisper);
      await _reflection.saveReflection(dateId, summary);
    } catch (_) {}

    try {
      final mood = await _emotional.analyzeMessages(nonWhisper);
      await _firestore.saveMoodChartNew(
        user.uid,
        dateId,
        happiness: mood.happiness,
        anxiety: mood.anxiety,
        stress: mood.stress,
        energy: mood.energy,
      );
    } catch (_) {}
  }

  Future<int> deleteWhisperMessages(String dateId) async {
    final user = _auth.currentUser;
    if (user == null) return 0;
    return _firestore.deleteWhisperSessionMessages(user.uid, dateId);
  }
}

final chatService = ChatService();
