import 'package:flutter/foundation.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../services/token_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'package:uuid/uuid.dart';

class ChatProvider with ChangeNotifier {
  final GeminiService _geminiService;
  final StorageService _storageService;
  final TokenService _tokenService;

  bool _isStreaming = false;
  String? _activeConversationId;
  List<Message> _messages = [];
  List<Conversation> _conversations = [];
  String _streamBuffer = '';

  ChatProvider(this._geminiService, this._storageService, this._tokenService) {
    loadConversations();
  }

  bool get isStreaming => _isStreaming;
  String? get activeConversationId => _activeConversationId;
  List<Message> get messages => _messages;
  List<Conversation> get conversations => _conversations;
  String get streamBuffer => _streamBuffer;

  // Load all conversations
  void loadConversations() {
    _conversations = _storageService.getConversations();
    notifyListeners();
  }

  // Load a specific conversation
  void loadConversation(String id) {
    _activeConversationId = id;
    _messages = _storageService.getMessages(id);
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
    loadConversations();
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

    // Check API key
    final settings = _storageService.getSettings();
    final apiKey = settings.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      _addErrorMessage('⚠️ Please set your Gemini API key in Settings first.');
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

    // Update conversation title from first message
    if (_messages.where((m) => m.role == 'user').length == 1) {
      final conv = _storageService.getConversation(_activeConversationId!);
      if (conv != null) {
        conv.title = text.length > 40 ? '${text.substring(0, 40)}...' : text;
        await conv.save();
      }
    }

    loadConversations();
    notifyListeners();

    // 2. Start streaming
    _isStreaming = true;
    _streamBuffer = '';
    notifyListeners();

    try {
      // 3. Call Gemini API
      final model = settings.selectedModel;
      debugPrint('Using model: $model with key: ${apiKey.substring(0, 5)}...');

      final stream = _geminiService.chatStream(
        apiKey: apiKey,
        messages: _messages,
        model: model,
      );

      // 4. Stream response
      await for (final chunk in stream) {
        _streamBuffer += chunk;
        notifyListeners();
      }

      // 5. Finalize AI message
      if (_streamBuffer.isNotEmpty) {
        final aiMessage = Message(
          id: const Uuid().v4(),
          conversationId: _activeConversationId!,
          role: 'assistant',
          content: _streamBuffer,
          createdAt: DateTime.now(),
        );
        _messages.add(aiMessage);
        await _storageService.saveMessage(aiMessage);
      } else {
        _addErrorMessage('⚠️ Received empty response from Gemini. Please try again.');
      }
    } catch (e) {
      debugPrint('Gemini Error: $e');
      _addErrorMessage('❌ Error: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      _isStreaming = false;
      _streamBuffer = '';
      loadConversations();
      notifyListeners();
    }
  }

  void _addErrorMessage(String errorText) {
    final errorMsg = Message(
      id: const Uuid().v4(),
      conversationId: _activeConversationId!,
      role: 'assistant',
      content: errorText,
      createdAt: DateTime.now(),
    );
    _messages.add(errorMsg);
    notifyListeners();
  }
}
