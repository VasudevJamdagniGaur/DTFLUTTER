import '../core/utils/date_utils.dart';
import '../models/chat_message.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'vertex_api_client.dart';

/// AI chat companion — simplified port of `chatService.js` (Vertex backend).
class ChatService {
  ChatService({
    VertexApiClient? vertex,
    FirestoreService? firestore,
    AuthService? auth,
  })  : _vertex = vertex ?? vertexApiClient,
        _firestore = firestore ?? firestoreService,
        _auth = auth ?? authService;

  final VertexApiClient _vertex;
  final FirestoreService _firestore;
  final AuthService _auth;

  static const _systemPrompt = '''
You are Detea, a warm, thoughtful emotional wellness companion. Listen deeply,
validate feelings, ask gentle follow-up questions, and help users reflect on
their day. Keep responses concise (2-4 sentences unless they need more).
Never give medical diagnoses. Be supportive, human, and non-judgmental.
''';

  Future<String> sendMessage({
    required String userText,
    required List<ChatMessage> history,
    String? dateId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in');

    final id = dateId ?? DeiteDateUtils.getDateId();
    await _firestore.addMessage(user.uid, id, {
      'sender': 'user',
      'text': userText,
      'isWhisperSession': false,
    });

    final conversation = history
        .where((m) => !m.isWhisperSession)
        .map((m) => '${m.sender == 'user' ? 'User' : 'Detea'}: ${m.text}')
        .join('\n');

    final prompt = '''
$_systemPrompt

Conversation so far:
$conversation
User: $userText
Detea:''';

    if (!_vertex.isConfigured) {
      throw Exception(
        'AI backend not configured. Set BACKEND_URL dart-define.',
      );
    }

    final reply = await _vertex.chat(prompt.trim());
    await _firestore.addMessage(user.uid, id, {
      'sender': 'ai',
      'text': reply,
      'isWhisperSession': false,
    });
    return reply;
  }

  Future<List<ChatMessage>> loadMessages([String? dateId]) async {
    final user = _auth.currentUser;
    if (user == null) return [];
    final id = dateId ?? DeiteDateUtils.getDateId();
    return _firestore.getMessages(user.uid, id);
  }

  Stream<List<ChatMessage>> watchMessages([String? dateId]) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    final id = dateId ?? DeiteDateUtils.getDateId();
    return _firestore.watchMessages(user.uid, id);
  }
}

final chatService = ChatService();
