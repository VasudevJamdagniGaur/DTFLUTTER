import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

/// Bottom nav — mirrors `BottomNavigation.js` (Home, Wellbeing, Pod, Community).
class DeiteBottomNavigation extends StatelessWidget {
  const DeiteBottomNavigation({super.key, required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bg = isDark ? const Color(0xFF262626) : Colors.white;

    return Material(
      color: isDark ? Colors.black : Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                active: currentPath == '/dashboard',
                isDark: isDark,
                onTap: () => context.go('/dashboard'),
              ),
              _NavItem(
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                active: currentPath == '/wellbeing',
                isDark: isDark,
                onTap: () => context.go('/wellbeing'),
              ),
              _NavItem(
                icon: Icons.groups_outlined,
                activeIcon: Icons.groups,
                active: currentPath == '/pod',
                isDark: isDark,
                onTap: () => context.go('/pod'),
              ),
              _NavItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                active: currentPath == '/community',
                isDark: isDark,
                onTap: () => context.go('/community'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280));

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Icon(
          active ? activeIcon : icon,
          color: color.withValues(alpha: active ? 1 : 0.4),
          size: 28,
        ),
      ),
    );
  }
}

bool showBottomNav(String path) {
  return path == '/dashboard' ||
      path == '/pod' ||
      path == '/community' ||
      path == '/wellbeing';
}
