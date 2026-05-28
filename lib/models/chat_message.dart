class ChatMessage {
  const ChatMessage({
    this.id,
    required this.sender,
    required this.text,
    this.isWhisperSession = false,
    this.timestamp,
    this.image,
    this.imageUrl,
  });

  final String? id;
  final String sender; // 'user' | 'ai'
  final String text;
  final bool isWhisperSession;
  final DateTime? timestamp;
  final String? image;
  final String? imageUrl;

  factory ChatMessage.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime? ts;
    final rawTs = map['ts'];
    if (rawTs != null) {
      if (rawTs is DateTime) {
        ts = rawTs;
      } else {
        try {
          ts = (rawTs as dynamic).toDate() as DateTime?;
        } catch (_) {
          ts = map['timestamp'] as DateTime?;
        }
      }
    }
    return ChatMessage(
      id: id ?? map['id'] as String?,
      sender: map['sender'] as String? ?? 'user',
      text: map['text'] as String? ?? '',
      isWhisperSession: map['isWhisperSession'] == true,
      timestamp: ts ?? map['timestamp'] as DateTime?,
      image: map['image'] as String?,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'sender': sender,
        'text': text,
        'isWhisperSession': isWhisperSession,
        if (image != null) 'image': image,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}
