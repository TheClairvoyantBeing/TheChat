import '../models/conversation.dart';
import '../models/message.dart';

class TokenService {
  final int maxTokens;

  TokenService({this.maxTokens = 8192}); // Groq default

  Future<int> checkUsage(List<Message> messages, String apiKey) async {
    // TODO: Use more advanced tokenizer if needed.
    // For now, heuristic: 1 token ~= 4 chars (English)
    int count = 0;
    for (var m in messages) {
       count += (m.content.length / 4).ceil();
    }
    return count;
  }

  // Simplified context window management
  List<Message> optimizeContext(List<Message> messages) {
     if (messages.length > 20) {
        // Keep system prompt + last 20 messages
        final system = messages.where((m) => m.role == 'system').toList();
        final recent = messages.sublist(messages.length - 20);
        return [...system, ...recent];
     }
     return messages;
  }
}
