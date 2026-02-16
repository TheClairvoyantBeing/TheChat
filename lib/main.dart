/// TheChat — App entry point and theme configuration.
///
/// Initializes core services (Storage, Token, Groq) and sets up
/// the Provider-based dependency injection tree before launching
/// the MaterialApp with light/dark theme support.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/groq_service.dart';
import 'services/storage_service.dart';
import 'services/token_service.dart';
import 'providers/chat_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent storage (Hive boxes for conversations, messages, settings)
  final storageService = StorageService();
  await storageService.init();

  // Token estimation and context window management
  final tokenService = TokenService();

  // Groq API client for streaming chat completions
  final groqService = GroqService(tokenService);

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<TokenService>.value(value: tokenService),
        Provider<GroqService>.value(value: groqService),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(groqService, storageService, tokenService),
        ),
      ],
      child: const TheChatApp(),
    ),
  );
}

/// Root widget that configures theming and responds to dark mode changes.
///
/// Listens to the settings Hive box so theme changes take effect immediately
/// without needing to restart the app.
class TheChatApp extends StatelessWidget {
  const TheChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();

    // Rebuild whenever settings change (e.g., dark mode toggle)
    return ValueListenableBuilder(
      valueListenable: storage.settingsListenable,
      builder: (context, box, _) {
        final settings = box.get('default');
        final isDarkMode = settings?.isDarkMode ?? true;

        return MaterialApp(
          title: 'TheChat',
          debugShowCheckedModeBanner: false,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.interTextTheme(),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
