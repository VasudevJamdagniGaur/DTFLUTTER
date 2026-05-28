import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/hub_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.dateId,
    this.isWhisperMode = false,
    this.isFreshSession = false,
  });

  final String? dateId;
  final bool isWhisperMode;
  final bool isFreshSession;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  List<ChatMessage> _messages = [];
  bool _loading = false;
  bool _generatingReflection = false;
  bool _initialized = false;
  late String _dateId;
  late bool _whisper;
  late bool _fresh;
  Uint8List? _pendingImage;
  final _imagePicker = ImagePicker();

  static const _welcomeId = '__welcome__';

  @override
  void initState() {
    super.initState();
    _dateId = widget.dateId ?? DeiteDateUtils.getDateId();
    _whisper = widget.isWhisperMode;
    _fresh = widget.isFreshSession;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final q = GoRouterState.of(context).uri.queryParameters;
    if (widget.dateId == null && q['dateId'] != null) {
      _dateId = q['dateId']!;
    }
    if (!widget.isWhisperMode) {
      _whisper = q['whisper'] == '1' || q['whisper'] == 'true';
    }
    if (!widget.isFreshSession) {
      _fresh = q['fresh'] == '1' || q['fresh'] == 'true' || _whisper;
    }
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (_fresh || _whisper) {
      setState(() => _messages = [_welcomeMessage()]);
      return;
    }
    final msgs = await chatService.loadMessages(_dateId);
    if (!mounted) return;
    setState(() {
      _messages = msgs.isEmpty ? [_welcomeMessage()] : msgs;
    });
  }

  ChatMessage _welcomeMessage() {
    final text = _whisper
        ? 'Welcome to your Whisper Session. This is a private, fresh space just for you. What would you like to share in confidence today?'
        : "Hi! I'm Detea. How are you feeling today? I'm here to listen.";
    return ChatMessage(
      id: _welcomeId,
      sender: 'ai',
      text: text,
      isWhisperSession: _whisper,
    );
  }

  bool get _hasRealMessages => _messages.any(
        (m) => m.id != _welcomeId && m.sender == 'user' && m.text.isNotEmpty,
      );

  Future<void> _pickImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return;
    final raw = await file.readAsBytes();
    final compressed = await FlutterImageCompress.compressWithList(
      raw,
      quality: 75,
      minWidth: 1080,
    );
    setState(() => _pendingImage = compressed);
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    final image = _pendingImage;
    if ((text.isEmpty && image == null) || _loading) return;
    _input.clear();
    setState(() {
      _loading = true;
      _pendingImage = null;
      _messages = [
        ..._messages.where((m) => m.id != _welcomeId),
        ChatMessage(
          sender: 'user',
          text: text.isEmpty ? '[Shared a photo]' : text,
          isWhisperSession: _whisper,
        ),
      ];
    });
    _scrollToBottom();
    try {
      final history = _messages.where((m) => m.id != _welcomeId).toList();
      final reply = await chatService.sendMessage(
        userText: text,
        history: history,
        dateId: _dateId,
        isWhisperSession: _whisper,
        imageBytes: image,
      );
      if (!mounted) return;
      setState(() {
        _messages = [
          ..._messages,
          ChatMessage(sender: 'ai', text: reply, isWhisperSession: _whisper),
        ];
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _generateReflection() async {
    setState(() => _generatingReflection = true);
    try {
      await chatService.finalizeSession(
        dateId: _dateId,
        messages: _messages,
        isWhisperSession: _whisper,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reflection & mood saved!')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _generatingReflection = false);
    }
  }

  Future<bool> _onBack() async {
    if (_whisper && _hasRealMessages) {
      final delete = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: HubColors.bgSecondary,
          title: const Text('Leave Whisper Session?',
              style: TextStyle(color: HubColors.text)),
          content: const Text(
            'Your whisper messages will be deleted and cannot be recovered.',
            style: TextStyle(color: HubColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete & leave',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
      if (delete == true) {
        await chatService.deleteWhisperMessages(_dateId);
        if (mounted) context.go('/dashboard');
      }
      return false;
    }

    if (!_whisper && _hasRealMessages) {
      await chatService.finalizeSession(
        dateId: _dateId,
        messages: _messages,
        isWhisperSession: false,
      );
    }
    return true;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _whisper ? 'Whisper Session' : 'Chat with Detea';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _onBack();
        if (leave && mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: HubColors.bg,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: HubColors.bg,
          foregroundColor: HubColors.text,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final leave = await _onBack();
              if (leave && mounted) context.pop();
            },
          ),
          actions: [
            if (_messages.isNotEmpty && !_whisper)
              TextButton(
                onPressed: _generatingReflection ? null : _generateReflection,
                child: _generatingReflection
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
          ],
        ),
        body: Column(
          children: [
            if (_whisper)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: HubColors.accent.withValues(alpha: 0.15),
                child: const Text(
                  'Private session — messages are not saved to your daily reflection.',
                  style: TextStyle(color: HubColors.accentHighlight, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_loading ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _messages.length) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          color: HubColors.accent,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                  final m = _messages[i];
                  final isUser = m.sender == 'user';
                  final img = m.imageUrl ?? (m.image?.startsWith('http') == true ? m.image : null);
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? HubColors.accent
                            : HubColors.bgSecondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (img != null && img.startsWith('http'))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: img,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          if (m.text.isNotEmpty &&
                              m.text != '[Shared a photo]')
                            Text(
                              m.text,
                              style: TextStyle(
                                color: isUser ? Colors.white : HubColors.text,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_pendingImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _pendingImage!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _pendingImage = null),
                      ),
                    ),
                  ],
                ),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _pickImage,
                      icon: Icon(
                        Icons.image_outlined,
                        color: _pendingImage != null
                            ? HubColors.accentHighlight
                            : HubColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _input,
                        maxLines: 4,
                        minLines: 1,
                        style: const TextStyle(color: HubColors.text),
                        decoration: InputDecoration(
                          hintText: _whisper
                              ? 'Share confidentially...'
                              : 'Share what\'s on your mind...',
                          filled: true,
                          fillColor: HubColors.bgSecondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _loading ||
                              (_input.text.trim().isEmpty &&
                                  _pendingImage == null)
                          ? null
                          : _send,
                      icon: const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        backgroundColor: HubColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
