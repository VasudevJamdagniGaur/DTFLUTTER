import '../models/chat_message.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'vertex_api_client.dart';

/// Day reflection generation — port of `reflectionService.js`.
class ReflectionService {
  ReflectionService({
    VertexApiClient? vertex,
    FirestoreService? firestore,
    AuthService? auth,
  })  : _vertex = vertex ?? vertexApiClient,
        _firestore = firestore ?? firestoreService,
        _auth = auth ?? authService;

  final VertexApiClient _vertex;
  final FirestoreService _firestore;
  final AuthService _auth;

  static const _greetings = {
    'hey',
    'hi',
    'hello',
    'hii',
    'sup',
    'yo',
  };

  bool _isSimpleGreeting(String text) {
    final clean = text.toLowerCase().trim().replaceAll(RegExp(r'[!.]$'), '');
    return _greetings.contains(clean);
  }

  Future<String> generateReflection(List<ChatMessage> messages) async {
    if (messages.isEmpty) {
      return 'Had a brief chat with Detea today.';
    }

    final userMessages = messages
        .where((m) => m.sender == 'user' && !m.isWhisperSession)
        .map((m) => m.text.trim())
        .where((t) => !_isSimpleGreeting(t) && t.length > 3)
        .toList();

    if (userMessages.isEmpty) {
      return "Had a brief chat with Detea today but didn't share much.";
    }

    if (!_vertex.isConfigured) {
      return _fallbackSummary(userMessages);
    }

    try {
      final conversation = messages
          .where((m) => !m.isWhisperSession)
          .map((m) => {
                'role': m.sender == 'user' ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList();
      return await _vertex.reflection(conversation);
    } catch (_) {
      return _fallbackSummary(userMessages);
    }
  }

  String _fallbackSummary(List<String> userMessages) {
    if (userMessages.length == 1) {
      return 'Today I shared: "${userMessages.first}"';
    }
    return 'Today I chatted with Detea about ${userMessages.length} things on my mind.';
  }

  Future<String?> loadReflection(String dateId) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final result = await _firestore.getReflectionNew(user.uid, dateId);
    return result.reflection;
  }

  Future<void> saveReflection(String dateId, String summary) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.saveReflectionNew(
      user.uid,
      dateId,
      summary: summary,
    );
  }
}

final reflectionService = ReflectionService();
