import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/theme_provider.dart';
import 'screens/chat_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.instance;
    return ListenableBuilder(
      listenable: theme,
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'Dom Eliseu',
          theme: ThemeData(
            brightness: theme.isDark ? Brightness.dark : Brightness.light,
            colorSchemeSeed: theme.color,
          ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('pt', 'BR')],
          home: const ChatPage(),
        );
      }
    );
  }
}
