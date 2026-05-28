import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Android-style back handling — mirrors `App.js` hardware back routes.
class BackNavigationHandler extends StatelessWidget {
  const BackNavigationHandler({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack(context);
      },
      child: child,
    );
  }

  void _handleBack(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    switch (path) {
      case '/chat':
        // ChatScreen handles whisper warnings via its own PopScope
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
        return;
      case '/wellbeing':
      case '/profile':
      case '/help-improve-deite':
        context.go('/dashboard');
      case '/share-suggestions':
      case '/tea-feed':
        context.go('/dashboard');
      case '/watchlist':
        context.go('/community');
      case '/community':
      case '/pod':
        context.go('/dashboard');
      case '/pod/chat':
      case '/pod/reflections':
        context.go('/pod');
      case '/pod/sports':
        context.go('/pod');
      case '/pod/ai-tech':
      case '/pod/entrepreneurship':
      case '/pod/current-affairs':
        context.go('/pod');
      case '/login':
        context.go('/signup');
      case '/dashboard':
      case '/':
      case '/landing':
        // Let system handle exit on root tabs
        if (context.canPop()) {
          context.pop();
        }
      default:
        if (path.startsWith('/pod/sports/topic/')) {
          context.go('/pod/sports');
        } else if (path.startsWith('/pod/explore/')) {
          final parts = path.split('/').where((s) => s.isNotEmpty).toList();
          final sec = parts.length > 2 ? parts[2] : '';
          final home = switch (sec) {
            'ai-tech' => '/pod/ai-tech',
            'entrepreneurship' => '/pod/entrepreneurship',
            'current-affairs' => '/pod/current-affairs',
            _ => '/pod',
          };
          context.go(home);
        } else if (path.startsWith('/user/')) {
          if (context.canPop()) context.pop();
        } else if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
    }
  }
}
