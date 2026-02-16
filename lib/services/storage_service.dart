import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/app_settings.dart';

class StorageService {
  late Box<Conversation> _conversationsBox;
  late Box<Message> _messagesBox;
  late Box<AppSettings> _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ConversationAdapter());
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    _conversationsBox = await Hive.openBox<Conversation>('conversations');
    _messagesBox = await Hive.openBox<Message>('messages');
    _settingsBox = await Hive.openBox<AppSettings>('settings');
    
    // Create default settings if not exist
    if (_settingsBox.isEmpty) {
      await _settingsBox.put('default', AppSettings());
    }
  }

  // Settings
  AppSettings getSettings() => _settingsBox.get('default')!;
  Future<void> saveSettings(AppSettings settings) => _settingsBox.put('default', settings);
  ValueListenable<Box<AppSettings>> get settingsListenable => _settingsBox.listenable();

  // Conversations
  List<Conversation> getConversations() => _conversationsBox.values.toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Sort by newest

  Conversation? getConversation(String id) => _conversationsBox.get(id);

  Future<void> saveConversation(Conversation conversation) async {
    await _conversationsBox.put(conversation.id, conversation);
  }

  Future<void> deleteConversation(String id) async {
    await _conversationsBox.delete(id);
    // Also delete messages for this conversation
    final keys = _messagesBox.values
        .where((m) => m.conversationId == id)
        .map((m) => m.key)
        .toList();
    await _messagesBox.deleteAll(keys);
  }

  // Messages
  List<Message> getMessages(String conversationId) {
    return _messagesBox.values
        .where((m) => m.conversationId == conversationId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Oldest first
  }

  Future<void> saveMessage(Message message) async {
    // Generate UUID if needed or assume provider handles ID
    await _messagesBox.put(message.id, message);
    
    // Update conversation message count & timestamp
    final conv = _conversationsBox.get(message.conversationId);
    if (conv != null) {
      conv.updatedAt = DateTime.now();
      conv.messageCount = (conv.messageCount) + 1;
      await conv.save();
    }
  }
}
