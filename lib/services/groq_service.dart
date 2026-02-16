/// GroqService — HTTP client for Groq's chat completions API.
///
/// Makes streaming requests to `https://api.groq.com/openai/v1/chat/completions`
/// and yields text deltas as they arrive via Server-Sent Events (SSE).
/// This is the core AI inference layer of the app.
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import 'token_service.dart';

class GroqService {
  final TokenService _tokenService;

  /// Groq's OpenAI-compatible API base URL.
  static const String _baseUrl = 'https://api.groq.com/openai/v1';

  GroqService(this._tokenService);

  /// Streams chat completion tokens from the Groq API.
  ///
  /// Converts the app's [Message] list into an OpenAI-compatible messages
  /// payload, sends a streaming POST request, and yields each text chunk
  /// as it arrives via SSE (`data: {...}` lines).
  ///
  /// Throws an [Exception] if the API returns a non-200 status code.
  Stream<String> chatStream({
    required String apiKey,
    required List<Message> messages,
    required String model,
  }) async* {
    try {
      // Trim conversation history to fit context window
      final optimized = _tokenService.optimizeContext(messages);

      // Build OpenAI-compatible messages array
      final List<Map<String, String>> apiMessages = [];
      for (final msg in optimized) {
        apiMessages.add({
          'role': msg.role, // 'user', 'assistant', or 'system'
          'content': msg.content,
        });
      }

      // Construct streaming HTTP request
      final request = http.Request(
        'POST',
        Uri.parse('$_baseUrl/chat/completions'),
      );
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      });
      request.body = jsonEncode({
        'model': model,
        'messages': apiMessages,
        'stream': true,
        'temperature': 0.7,
        'max_completion_tokens': 8192,
      });

      final client = http.Client();
      try {
        final response = await client.send(request);

        // Handle API errors (invalid key, rate limit, etc.)
        if (response.statusCode != 200) {
          final body = await response.stream.bytesToString();
          final errorData = jsonDecode(body);
          final errorMsg = errorData['error']?['message'] ?? 'Unknown error (${response.statusCode})';
          throw Exception('Groq API Error: $errorMsg');
        }

        // Parse SSE stream — each line starting with "data: " contains a JSON chunk
        final stream = response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in stream) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();

            // "data: [DONE]" signals end of stream
            if (data == '[DONE]') break;

            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'];
              if (content != null && content.isNotEmpty) {
                yield content;
              }
            } catch (e) {
              // Skip malformed JSON chunks (occasionally happens with SSE)
              debugPrint('Skipping malformed SSE chunk: $e');
            }
          }
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Groq API Error: $e');
      if (e is Exception) rethrow;
      throw Exception('Groq API Error: $e');
    }
  }

  /// Validates a Groq API key by making a minimal non-streaming request.
  ///
  /// Sends a single "Hi" message with a tiny token limit. If the key is
  /// invalid or expired, the API will return an error which we surface
  /// as an exception.
  Future<void> validateApiKey(String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': 'Hi'}
          ],
          'max_completion_tokens': 5,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        final errorMsg = errorData['error']?['message'] ?? 'Unknown error';
        throw Exception('Invalid API Key: $errorMsg');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Invalid API Key: $e');
    }
  }
}
