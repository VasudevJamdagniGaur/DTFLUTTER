import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String _returnTo(BuildContext context, {String fallback = '/dashboard'}) {
    final extra = GoRouterState.of(context).extra;
    if (extra is Map) {
      final rt = extra['returnTo'];
      if (rt is String && rt.startsWith('/')) return rt;
    }
    return fallback;
  }

  void _exitApp() {
    SystemNavigator.pop();
  }

  void _handleBack(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    switch (path) {
      case '/chat':
        // ChatScreen handles whisper warnings via its own PopScope.
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
        return;

      case '/share-suggestions':
        context.go(_returnTo(context));
        return;

      case '/tea-feed':
        context.go(_returnTo(context));
        return;

      case '/watchlist':
        context.go('/community');
        return;

      case '/community':
        context.go('/dashboard');
        return;

      case '/pod/chat':
      case '/pod/reflections':
        context.go('/pod');
        return;

      case '/pod/sports':
      case '/pod/ai-tech':
      case '/pod/entrepreneurship':
      case '/pod/current-affairs':
        context.go('/pod');
        return;

      case '/pod':
        context.go('/dashboard');
        return;

      case '/login':
        context.go('/signup');
        return;

      case '/dashboard':
        _exitApp();
        return;

      case '/':
      case '/landing':
        _exitApp();
        return;

      default:
        if (path.startsWith('/user/')) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/dashboard');
          }
          return;
        }
        if (path.startsWith('/pod/sports/topic/')) {
          context.go('/pod/sports');
          return;
        }
        if (path.startsWith('/pod/explore/')) {
          final parts = path.split('/').where((s) => s.isNotEmpty).toList();
          final sec = parts.length > 2 ? parts[2] : '';
          final home = switch (sec) {
            'ai-tech' => '/pod/ai-tech',
            'entrepreneurship' => '/pod/entrepreneurship',
            'current-affairs' => '/pod/current-affairs',
            _ => '/pod',
          };
          context.go(home);
          return;
        }
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
    }
  }
}
