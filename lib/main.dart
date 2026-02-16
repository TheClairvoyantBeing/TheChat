import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart'; // For ValueListenableBuilder on Box

import 'services/gemini_service.dart';
import 'services/storage_service.dart';
import 'services/token_service.dart';
import 'providers/chat_provider.dart';
import 'screens/home_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  final storageService = StorageService();
  await storageService.init();

  final tokenService = TokenService();
  final geminiService = GeminiService(tokenService);

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<TokenService>.value(value: tokenService),
        Provider<GeminiService>.value(value: geminiService),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(geminiService, storageService, tokenService),
        ),
      ],
      child: const TheChatApp(),
    ),
  );
}

class TheChatApp extends StatelessWidget {
  const TheChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();

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
