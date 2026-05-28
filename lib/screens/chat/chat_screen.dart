import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../services/reflection_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  List<ChatMessage> _messages = [];
  bool _loading = false;
  bool _generatingReflection = false;
  late String _dateId;

  @override
  void initState() {
    super.initState();
    _dateId = DeiteDateUtils.getDateId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final q = GoRouterState.of(context).uri.queryParameters['dateId'];
      if (q != null && q.isNotEmpty) _dateId = q;
      _load();
    });
  }

  Future<void> _load() async {
    final msgs = await chatService.loadMessages(_dateId);
    if (mounted) setState(() => _messages = msgs);
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _loading) return;
    _input.clear();
    setState(() {
      _loading = true;
      _messages = [
        ..._messages,
        ChatMessage(sender: 'user', text: text),
      ];
    });
    _scrollToBottom();
    try {
      final reply = await chatService.sendMessage(
        userText: text,
        history: _messages,
        dateId: _dateId,
      );
      if (!mounted) return;
      setState(() {
        _messages = [
          ..._messages,
          ChatMessage(sender: 'ai', text: reply),
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
      final summary = await reflectionService.generateReflection(_messages);
      await reflectionService.saveReflection(_dateId, summary);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reflection saved!')),
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
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('Chat with Detea'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
        actions: [
          if (_messages.isNotEmpty)
            TextButton(
              onPressed: _generatingReflection ? null : _generateReflection,
              child: _generatingReflection
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Reflect'),
            ),
        ],
      ),
      body: Column(
        children: [
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
                    child: Text(
                      m.text,
                      style: TextStyle(
                        color: isUser ? Colors.white : HubColors.text,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      style: const TextStyle(color: HubColors.text),
                      decoration: InputDecoration(
                        hintText: 'Share what\'s on your mind...',
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
                    onPressed: _loading ? null : _send,
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
    );
  }
}
