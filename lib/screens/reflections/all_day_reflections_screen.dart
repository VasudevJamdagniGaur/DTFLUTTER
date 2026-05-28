import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  List<Map<String, dynamic>> _reflections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = authService.currentUser;
    if (user == null) return;
    final list = await firestoreService.getRecentReflections(user.uid, limit: 30);
    if (mounted) {
      setState(() {
        _reflections = list;
        _loading = false;
      });
    }
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
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: HubColors.accent),
            )
          : _reflections.isEmpty
              ? const Center(
                  child: Text(
                    'No reflections yet. Chat with Detea to create them.',
                    style: TextStyle(color: HubColors.textSecondary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reflections.length,
                    itemBuilder: (_, i) {
                      final r = _reflections[i];
                      final dateId = r['dateId'] as String? ?? '';
                      return Card(
                        color: HubColors.bgSecondary,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                            DeiteDateUtils.formatDateForDisplay(dateId),
                            style: const TextStyle(
                              color: HubColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            r['summary'] as String? ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: HubColors.textSecondary),
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: HubColors.textSecondary),
                          onTap: () => context.push('/chat?dateId=$dateId'),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
