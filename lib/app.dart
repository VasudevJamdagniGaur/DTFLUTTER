import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/navigation/back_navigation.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

class DeiteApp extends StatefulWidget {
  const DeiteApp({super.key});

  @override
  State<DeiteApp> createState() => _DeiteAppState();
}

class _DeiteAppState extends State<DeiteApp> {
  late final _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return BackNavigationHandler(
      child: MaterialApp.router(
        title: 'Deite',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
