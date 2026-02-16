import 'package:flutter/foundation.dart';
import '../services/groq_service.dart';
import '../services/storage_service.dart';
import '../services/token_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'package:uuid/uuid.dart';

class ChatProvider with ChangeNotifier {
  final GroqService _groqService;
  final StorageService _storageService;
  final TokenService _tokenService;

  bool _isStreaming = false;
  String? _activeConversationId;
  List<Message> _messages = [];
  List<Conversation> _conversations = [];
  String _streamBuffer = '';
  
  ChatProvider(this._groqService, this._storageService, this._tokenService) {
    loadConversations();
  }

  bool get isStreaming => _isStreaming;
  String? get activeConversationId => _activeConversationId;
  List<Message> get messages => _messages;
  List<Conversation> get conversations => _conversations;

  // Load all conversations
  void loadConversations() {
    _conversations = _storageService.getConversations();
    notifyListeners();
  }

  // Initialize: Load conversations from storage
  Future<void> loadConversation(String id) async {
    _activeConversationId = id;
    final convMessages = await _storageService.getMessages(id);
    _messages = convMessages;
    notifyListeners();
  }

  // Create new conversation
  Future<void> startNewConversation({String? initialMessage}) async {
    final newId = const Uuid().v4();
    final newConv = Conversation(
      id: newId,
      title: 'New Chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _storageService.saveConversation(newConv);
    _activeConversationId = newId;
    _messages = [];
    loadConversations(); // meaningful update
    notifyListeners();
    
    if (initialMessage != null) {
      await sendMessage(initialMessage);
    }
  }

  // Send message
  Future<void> sendMessage(String text) async {
    if (_activeConversationId == null) {
      await startNewConversation(initialMessage: text);
      return; 
    }

    // 1. Save user message
    final userMessage = Message(
      id: const Uuid().v4(),
      conversationId: _activeConversationId!,
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );
    _messages.add(userMessage);
    await _storageService.saveMessage(userMessage);
    loadConversations(); // To update 'updatedAt' or message count in list
    notifyListeners();

    // 2. Prepare AI response placeholder
    _isStreaming = true;
    _streamBuffer = '';
    notifyListeners();

    try {
      // 3. Call API
      final stream = await _groqService.chatStream(
        apiKey: _storageService.getSettings().apiKey!,
        conversation: _storageService.getConversation(_activeConversationId!), // Get conversation if needed
        messages: _messages,
        model: _storageService.getSettings().selectedModel,
      );

      // 4. Stream response
      await for (final chunk in stream) {
        _streamBuffer += chunk;
        notifyListeners(); // Update UI
      }

      // 5. Finalize AI message
      final aiMessage = Message(
        id: const Uuid().v4(),
        conversationId: _activeConversationId!,
        role: 'assistant',
        content: _streamBuffer,
        createdAt: DateTime.now(), // Or start time?
      );
      _messages.add(aiMessage);
      await _storageService.saveMessage(aiMessage);
      
      // Update tokens (async)
      // await _tokenService.trackUsage(_streamBuffer);

    } catch (e) {
      // Handle error (maybe add error message to chat)
      debugPrint('Error: $e');
    } finally {
      _isStreaming = false;
      _streamBuffer = '';
      notifyListeners();
    }
  }
}
