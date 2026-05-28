class ShareStyle {
  const ShareStyle({
    required this.id,
    required this.label,
    required this.instruction,
  });

  final String id;
  final String label;
  final String instruction;

  static const variants = [
    ShareStyle(
      id: 'minimal',
      label: 'Minimal',
      instruction:
          'Write a very clean, short post. 1-3 sentences, no fluff, max 1 hashtag.',
    ),
    ShareStyle(
      id: 'emotional',
      label: 'Emotional',
      instruction:
          'Write an expressive, personal and relatable post with warm tone.',
    ),
    ShareStyle(
      id: 'bold',
      label: 'Bold',
      instruction:
          'Write a confident, impactful post with strong language.',
    ),
    ShareStyle(
      id: 'witty',
      label: 'Witty',
      instruction: 'Write a clever post with light humor or wordplay.',
    ),
    ShareStyle(
      id: 'formal',
      label: 'Formal',
      instruction:
          'Write a polished professional post. No slang or emojis.',
    ),
  ];
}
