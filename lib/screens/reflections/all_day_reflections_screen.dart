import 'package:flutter/material.dart';

import '../../core/theme/hub_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class AllDayReflectionsScreen extends StatefulWidget {
  const AllDayReflectionsScreen({super.key});

  @override
  State<AllDayReflectionsScreen> createState() => _AllDayReflectionsScreenState();
}

class _AllDayReflectionsScreenState extends State<AllDayReflectionsScreen> {
  List<Map<String, dynamic>> _days = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = authService.currentUser;
    if (user == null) return;
    final days = await firestoreService.getAllChatDays(user.uid);
    if (mounted) setState(() => _days = days);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HubColors.bg,
      appBar: AppBar(
        title: const Text('All Reflections'),
        backgroundColor: HubColors.bg,
        foregroundColor: HubColors.text,
      ),
      body: _days.isEmpty
          ? const Center(
              child: Text(
                'No reflection days yet.',
                style: TextStyle(color: HubColors.textSecondary),
              ),
            )
          : ListView.builder(
              itemCount: _days.length,
              itemBuilder: (_, i) {
                final d = _days[i];
                final id = d['id'] as String? ?? d['date'] as String? ?? '';
                return ListTile(
                  title: Text(
                    DeiteDateUtils.formatDateForDisplay(id),
                    style: const TextStyle(color: HubColors.text),
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: HubColors.textSecondary),
                );
              },
            ),
    );
  }
}
