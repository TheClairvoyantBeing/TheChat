/// ChatProvider — Core state management for chat interactions.
///
/// Manages the active conversation, message list, and streaming state.
/// Coordinates between [GroqService] (API calls), [StorageService]
/// (persistence), and [TokenService] (context optimization).
library;

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

  /// Whether the AI is currently generating a response.
  bool _isStreaming = false;

  /// The ID of the currently active conversation.
  String? _activeConversationId;

  /// Messages in the active conversation (chronological order).
  List<Message> _messages = [];

  /// All conversations sorted by most recent.
  List<Conversation> _conversations = [];

  /// Accumulates streaming response text as chunks arrive from the API.
  String _streamBuffer = '';

  ChatProvider(this._groqService, this._storageService, this._tokenService) {
    loadConversations();
  }

  // -- Public getters --

  bool get isStreaming => _isStreaming;
  String? get activeConversationId => _activeConversationId;
  List<Message> get messages => _messages;
  List<Conversation> get conversations => _conversations;
  String get streamBuffer => _streamBuffer;

  /// Loads all conversations from local storage.
  void loadConversations() {
    _conversations = _storageService.getConversations();
    notifyListeners();
  }

  /// Switches to a specific conversation and loads its messages.
  void loadConversation(String id) {
    _activeConversationId = id;
    _messages = _storageService.getMessages(id);
    notifyListeners();
  }

  /// Creates a new empty conversation. Optionally sends an initial message.
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

  /// Sends a user message and streams the AI response.
  ///
  /// Flow:
  /// 1. Validates the API key exists.
  /// 2. Saves the user message to local storage.
  /// 3. Auto-titles the conversation from the first user message.
  /// 4. Calls [GroqService.chatStream] and accumulates streaming tokens.
  /// 5. Saves the completed AI response to local storage.
  Future<void> sendMessage(String text) async {
    // If no active conversation, create one first
    if (_activeConversationId == null) {
      await startNewConversation(initialMessage: text);
      return;
    }

    // Validate API key is configured
    final settings = _storageService.getSettings();
    final apiKey = settings.apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      _addErrorMessage('⚠️ Please set your Groq API key in Settings first.');
      return;
    }

    // Save user message locally
    final userMessage = Message(
      id: const Uuid().v4(),
      conversationId: _activeConversationId!,
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );
    _messages.add(userMessage);
    await _storageService.saveMessage(userMessage);

    // Auto-title: use the first user message as the conversation title
    if (_messages.where((m) => m.role == 'user').length == 1) {
      final conv = _storageService.getConversation(_activeConversationId!);
      if (conv != null) {
        conv.title = text.length > 40 ? '${text.substring(0, 40)}...' : text;
        await conv.save();
      }
    }

    loadConversations();
    notifyListeners();

    // Begin streaming AI response
    _isStreaming = true;
    _streamBuffer = '';
    notifyListeners();

    try {
      final model = settings.selectedModel;
      debugPrint('Using model: $model with key: ${apiKey.substring(0, 5)}...');

      // Stream tokens from Groq API
      final stream = _groqService.chatStream(
        apiKey: apiKey,
        messages: _messages,
        model: model,
      );

      await for (final chunk in stream) {
        _streamBuffer += chunk;
        notifyListeners(); // Update UI with each new token
      }

      // Save completed response
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
        _addErrorMessage('⚠️ Received empty response from Groq. Please try again.');
      }
    } catch (e) {
      debugPrint('Groq Error: $e');
      _addErrorMessage('❌ Error: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      _isStreaming = false;
      _streamBuffer = '';
      loadConversations();
      notifyListeners();
    }
  }

  /// Adds an error message to the chat as a system-generated assistant bubble.
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
