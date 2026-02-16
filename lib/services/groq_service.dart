import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'token_service.dart';

class GroqService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  final TokenService _tokenService;

  GroqService(this._tokenService);

  Stream<String> chatStream({
    required String apiKey,
    required List<Message> messages,
    required String model,
  }) async* {
    try {
      // 1. Prepare messages (optimize context if needed)
      final optimizedMessages = _tokenService.optimizeContext(messages);

      // 2. Prepare request
      final data = {
        'model': model,
        'messages': optimizedMessages.map((m) => {
              'role': m.role,
              'content': m.content,
            }).toList(),
        'stream': true,
        'temperature': 0.7,
      };

      // 3. Make request
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
        data: data,
      );

      // 4. Parse stream
      final Stream<List<int>> byteStream = response.data.stream;
      final lines = byteStream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        if (line.startsWith('data: ')) {
          final payload = line.substring(6);
          if (payload == '[DONE]') return;
          try {
            final json = jsonDecode(payload);
            final content =
                json['choices']?[0]?['delta']?['content'] as String? ?? '';
            if (content.isNotEmpty) {
              yield content;
            }
          } catch (_) {
            // Skip malformed chunks
          }
        }
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(
            'Groq API Error: ${e.response?.statusCode} - ${e.response?.statusMessage}');
      }
      rethrow;
    }
  }

  Future<void> validateApiKey(String apiKey) async {
    try {
      await _dio.get(
        'https://api.groq.com/openai/v1/models',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );
    } catch (e) {
      throw Exception('Invalid API Key');
    }
  }
}
