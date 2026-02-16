/// TokenService — Context window management and token estimation.
///
/// Provides lightweight token counting (heuristic: 1 token ≈ 4 characters)
/// and conversation trimming to keep API requests within model context limits.
library;

import '../models/message.dart';

class TokenService {
  /// Maximum tokens allowed in the context window.
  final int maxTokens;

  TokenService({this.maxTokens = 8192});

  /// Estimates the total token count for a list of messages.
  ///
  /// Uses a simple heuristic (1 token ≈ 4 English characters).
  /// This is intentionally lightweight — actual token counts come back
  /// from the Groq API response's `usage` field.
  Future<int> checkUsage(List<Message> messages, String apiKey) async {
    int count = 0;
    for (var m in messages) {
      count += (m.content.length / 4).ceil();
    }
    return count;
  }

  /// Trims the message list to fit within the context window.
  ///
  /// Strategy:
  /// - If there are more than 20 messages, keep all system prompts
  ///   plus only the 20 most recent messages.
  /// - Otherwise, return the full message list unchanged.
  ///
  /// This prevents context overflow while preserving system instructions
  /// and recent conversation flow.
  List<Message> optimizeContext(List<Message> messages) {
    if (messages.length > 20) {
      // Preserve system prompts (always relevant)
      final system = messages.where((m) => m.role == 'system').toList();
      // Keep only the most recent 20 messages
      final recent = messages.sublist(messages.length - 20);
      return [...system, ...recent];
    }
    return messages;
  }
}
