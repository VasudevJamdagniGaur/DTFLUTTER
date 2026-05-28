class CrewMessage {
  const CrewMessage({
    required this.id,
    required this.senderUid,
    required this.sender,
    required this.message,
    this.image,
    this.timestamp,
  });

  final String id;
  final String senderUid;
  final String sender;
  final String message;
  final String? image;
  final DateTime? timestamp;

  factory CrewMessage.fromMap(String id, Map<String, dynamic> m) {
    DateTime? ts;
    final raw = m['timestamp'] ?? m['createdAt'];
    if (raw is DateTime) {
      ts = raw;
    }
    return CrewMessage(
      id: id,
      senderUid: m['senderUid'] as String? ?? '',
      sender: m['senderName'] as String? ?? m['sender'] as String? ?? 'User',
      message: m['message'] as String? ?? '',
      image: m['image'] as String?,
      timestamp: ts,
    );
  }
}
