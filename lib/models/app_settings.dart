import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 2)
class AppSettings extends HiveObject {
  @HiveField(0)
  String? apiKey;

  @HiveField(1)
  String selectedModel;

  @HiveField(2)
  bool isDarkMode;

  @HiveField(3)
  bool showTokenUsage;

  AppSettings({
    this.apiKey,
    this.selectedModel = 'gemini-2.0-flash',
    this.isDarkMode = true,
    this.showTokenUsage = true,
  });
}
