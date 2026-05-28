import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'deite_bottom_navigation.dart';

/// Shell with optional bottom navigation for main tab routes.
class DeiteScaffold extends StatelessWidget {
  const DeiteScaffold({
    super.key,
    required this.child,
    this.showNav = false,
    this.appBar,
    this.floatingActionButton,
  });

  final Widget child;
  final bool showNav;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return Scaffold(
      appBar: appBar,
      body: child,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar:
          showNav ? DeiteBottomNavigation(currentPath: path) : null,
    );
  }
}
