/// Conversation — Chat session metadata stored via Hive.
///
/// Tracks a conversation's identity and lifecycle. The actual messages
/// are stored separately in the messages Hive box, linked by [id].
///
/// Hive TypeId: 0.
library;

import 'package:hive/hive.dart';

part 'conversation.g.dart';

@HiveType(typeId: 0)
class Conversation extends HiveObject {
  /// Unique identifier (UUID v4).
  @HiveField(0)
  final String id;

  /// Display title — auto-set from the first user message.
  @HiveField(1)
  String title;

  /// When the conversation was first created.
  @HiveField(2)
  final DateTime createdAt;

  /// When the last message was added or modified.
  @HiveField(3)
  DateTime updatedAt;

  /// Total number of messages in this conversation.
  @HiveField(4)
  int messageCount;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
  });
}
