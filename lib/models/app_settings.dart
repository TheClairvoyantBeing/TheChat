/// AppSettings — Persistent user preferences stored via Hive.
///
/// Stores the Groq API key, selected model, theme preference,
/// and token usage visibility toggle. Hive TypeId: 2.
library;

import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 2)
class AppSettings extends HiveObject {
  /// The user's Groq API key (starts with `gsk_`). Null until configured.
  @HiveField(0)
  String? apiKey;

  /// The Groq model ID to use for chat completions.
  @HiveField(1)
  String selectedModel;

  /// Whether the app should use dark theme.
  @HiveField(2)
  bool isDarkMode;

  /// Whether to display token usage statistics (future feature).
  @HiveField(3)
  bool showTokenUsage;

  AppSettings({
    this.apiKey,
    this.selectedModel = 'llama-3.3-70b-versatile',
    this.isDarkMode = true,
    this.showTokenUsage = true,
  });
}
