import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/hub_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/reflection_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  String _reflection = '';
  bool _loadingReflection = false;
  String? _profilePicture;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('dashboard_selected_date_iso');
    if (saved != null) {
      final d = DateTime.tryParse(saved);
      if (d != null) setState(() => _selectedDate = d);
    }
    await _ensureUser();
    await _loadReflection();
    await _loadProfile();
  }

  Future<void> _ensureUser() async {
    final user = authService.currentUser;
    if (user == null) return;
    await firestoreService.ensureUser(
      user.uid,
      email: user.email,
      displayName: user.displayName ?? 'User',
    );
  }

  Future<void> _loadReflection() async {
    setState(() => _loadingReflection = true);
    final dateId = DeiteDateUtils.getDateId(_selectedDate);
    final text = await reflectionService.loadReflection(dateId);
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getString('reflection_$dateId');
    if (!mounted) return;
    setState(() {
      _reflection = text ?? local ?? '';
      _loadingReflection = false;
    });
  }

  Future<void> _loadProfile() async {
    final user = authService.currentUser;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getString('user_profile_picture_${user.uid}');
    final result = await firestoreService.getUser(user.uid);
    if (!mounted) return;
    setState(() {
      _profilePicture =
          result.data?['profilePicture'] as String? ?? local;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'dashboard_selected_date_iso',
      picked.toIso8601String(),
    );
    await _loadReflection();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final dateId = DeiteDateUtils.getDateId(_selectedDate);
    final dateLabel = DeiteDateUtils.formatDateForDisplay(_selectedDate);

    return Scaffold(
      backgroundColor: HubColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        theme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        color: HubColors.text,
                      ),
                      onPressed: theme.toggleTheme,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: _profilePicture != null
                            ? NetworkImage(_profilePicture!)
                            : null,
                        child: _profilePicture == null
                            ? const Icon(Icons.person, color: HubColors.text)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DeiteDateUtils.isToday(dateId) ? 'Today' : dateLabel,
                      style: const TextStyle(
                        color: HubColors.text,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDate,
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: HubColors.accent),
                          const SizedBox(width: 8),
                          Text(
                            dateLabel,
                            style: const TextStyle(
                              color: HubColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Daily reflection',
                      style: TextStyle(
                        color: HubColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: HubColors.bgSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: HubColors.divider),
                      ),
                      child: _loadingReflection
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: HubColors.accent,
                              ),
                            )
                          : Text(
                              _reflection.isEmpty
                                  ? 'Chat with Detea to generate your reflection for this day.'
                                  : _reflection,
                              style: TextStyle(
                                color: _reflection.isEmpty
                                    ? HubColors.textSecondary
                                    : HubColors.text,
                                height: 1.5,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () =>
                              context.push('/chat?dateId=$dateId'),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Chat with Detea'),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/reflections'),
                          icon: const Icon(Icons.history),
                          label: const Text('All reflections'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat?dateId=$dateId'),
        backgroundColor: HubColors.accent,
        icon: const Icon(Icons.add_comment),
        label: const Text('New chat'),
      ),
    );
  }
}
