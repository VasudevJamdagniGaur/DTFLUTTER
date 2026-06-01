import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fade route transition — mirrors `App.js` fadeIn / fadeOut between pages.
CustomTransitionPage<void> fadeTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

/// Tab routes inside the main shell should not fade (instant switch).
NoTransitionPage<void> noTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return NoTransitionPage<void>(key: key, child: child);
}
