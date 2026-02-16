import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/message.dart';
import 'token_service.dart';

class GeminiService {
  final TokenService _tokenService;

  GeminiService(this._tokenService);

  Stream<String> chatStream({
    required String apiKey,
    required List<Message> messages,
    required String model,
  }) async* {
    try {
      // 1. Create model instance
      final geminiModel = GenerativeModel(
        model: model,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 8192,
        ),
      );

      // 2. Prepare messages — convert to Gemini format
      final optimized = _tokenService.optimizeContext(messages);
      final history = <Content>[];
      Content? lastUserContent;

      for (final msg in optimized) {
        if (msg.role == 'user') {
          lastUserContent = Content.text(msg.content);
        } else if (msg.role == 'assistant') {
          // If there's a pending user message before this assistant message, add both to history
          if (lastUserContent != null) {
            history.add(lastUserContent);
            history.add(Content.model([TextPart(msg.content)]));
            lastUserContent = null;
          }
        }
        // Skip system messages for now (Gemini handles them differently)
      }

      // 3. Start chat and stream response
      final chat = geminiModel.startChat(history: history);

      // The last message should be the user's latest message
      final lastMessage = messages.last;
      final response = chat.sendMessageStream(Content.text(lastMessage.content));

      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null && text.isNotEmpty) {
          yield text;
        }
      }
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      if (e is GenerativeAIException) {
        throw Exception('Gemini API Error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<void> validateApiKey(String apiKey) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
      );
      // Simple validation — try to generate a tiny response
      await model.generateContent([Content.text('Hi')]);
    } catch (e) {
      throw Exception('Invalid API Key: $e');
    }
  }
}
