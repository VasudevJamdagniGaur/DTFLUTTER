import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/hub_colors.dart';
import '../../models/crew_message.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class PodGroupChatScreen extends StatefulWidget {
  const PodGroupChatScreen({super.key});

  @override
  State<PodGroupChatScreen> createState() => _PodGroupChatScreenState();
}

class _PodGroupChatScreenState extends State<PodGroupChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  String? _sphereId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = authService.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'Please sign in to join crew chat.';
      });
      return;
    }
    firestoreService.syncUserPodDocuments(user.uid);
    final result = await firestoreService.getUserCrewSphere(user.uid);
    if (!mounted) return;
    if (result.success && result.sphereId != null) {
      setState(() {
        _sphereId = result.sphereId;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _error =
            'No crew sphere yet. Crew enrollment creates a group when enough members join.';
      });
    }
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    final user = authService.currentUser;
    if (text.isEmpty || user == null || _sphereId == null) return;
    _input.clear();
    await firestoreService.saveCrewSphereMessage(
      _sphereId!,
      user.uid,
      senderName: user.displayName ?? 'User',
      message: text,
    );
    _scrollToBottom();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pod'),
        ),
        title: const Text("Crew Group Chat"),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: HubColors.accent))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: HubColors.textSecondary, height: 1.5),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<CrewMessage>>(
                        stream: firestoreService.watchCrewSphereMessages(_sphereId!),
                        builder: (context, snap) {
                          final messages = snap.data ?? [];
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToBottom();
                          });
                          if (messages.isEmpty) {
                            return const Center(
                              child: Text(
                                'Say hello to your crew!',
                                style: TextStyle(color: HubColors.textSecondary),
                              ),
                            );
                          }
                          return ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (_, i) {
                              final m = messages[i];
                              final isMe =
                                  m.senderUid == authService.currentUser?.uid;
                              return Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.sizeOf(context).width * 0.78,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? HubColors.accent
                                        : HubColors.bgSecondary,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!isMe)
                                        Text(
                                          m.sender,
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white70
                                                : HubColors.accentHighlight,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      Text(
                                        m.message,
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : HubColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
                                  hintText: 'Message your crew...',
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
                              onPressed: _send,
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
