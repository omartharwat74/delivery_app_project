import 'package:delivery_app_project/features/support/domain/entities/support_conversation.dart';

/// DTO for `GET /api/delivery/v1/support` response.
/// Top-level JSON shape (standard envelope):
/// {
///   "status": 200,
///   "data": {
///     "conversation": { "id": 1, "participant_type": "delivery", "status": "open", ... },
///     "messages": { "items": [ { "id": 1, "body": "...", "sender_type": "delivery", ... } ] }
///   }
/// }
class SupportConversationDto {
  const SupportConversationDto({
    required this.id,
    required this.status,
    required this.messages,
  });

  final int id;
  final String status;
  final List<SupportChatMsgDto> messages;

  factory SupportConversationDto.fromJson(Map<String, dynamic> json) {
    // Handles nested `data: { conversation: {...}, messages: { items: [...] } }`
    Map<String, dynamic> convJson = json;
    if (json.containsKey('conversation') && json['conversation'] is Map) {
      convJson = json['conversation'] as Map<String, dynamic>;
    }

    dynamic rawMessages = json['messages'];
    if (rawMessages is Map && rawMessages.containsKey('items')) {
      rawMessages = rawMessages['items'];
    }

    final List<SupportChatMsgDto> msgs = rawMessages is List
        ? rawMessages
              .whereType<Map<String, dynamic>>()
              .map(SupportChatMsgDto.fromJson)
              .toList()
        : const [];

    return SupportConversationDto(
      id: _parseInt(convJson['id']) ?? 0,
      status: (convJson['status'] as String?) ?? 'open',
      messages: msgs,
    );
  }

  SupportConversation toEntity() => SupportConversation(
    id: id,
    status: status,
    messages: messages.map((m) => m.toEntity()).toList(),
  );
}

/// DTO for a single support chat message.
class SupportChatMsgDto {
  const SupportChatMsgDto({
    required this.id,
    required this.body,
    required this.senderType,
    required this.imageUrl,
    required this.attachments,
    required this.createdAt,
  });

  final int id;
  final String? body;
  final String senderType;
  final String? imageUrl;
  final List<String> attachments;
  final DateTime createdAt;

  factory SupportChatMsgDto.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> msgJson = json;
    if (json.containsKey('message') && json['message'] is Map) {
      msgJson = json['message'] as Map<String, dynamic>;
    } else if (json.containsKey('data') && json['data'] is Map) {
      msgJson = json['data'] as Map<String, dynamic>;
    }

    List<String> parsedAttachments = [];
    if (msgJson['attachments'] is List) {
      parsedAttachments = (msgJson['attachments'] as List).map((e) {
        if (e is Map && e['url'] != null) {
          return e['url'].toString();
        }
        return e.toString();
      }).toList();
    } else if (msgJson['attachment'] is String) {
      parsedAttachments.add(msgJson['attachment'] as String);
    }

    return SupportChatMsgDto(
      id: _parseInt(msgJson['id']) ?? 0,
      body:
          (msgJson['body'] ??
                  msgJson['message'] ??
                  msgJson['content'] ??
                  msgJson['text'])
              ?.toString(),
      senderType:
          (msgJson['sender_type'] ?? msgJson['senderType'])?.toString() ??
          'delivery',
      imageUrl: msgJson['image_url'] as String?,
      attachments: parsedAttachments,
      createdAt: _parseDate(msgJson['created_at']),
    );
  }

  SupportChatMsg toEntity() => SupportChatMsg(
    id: id,
    body: body,
    senderType: senderType,
    imageUrl: imageUrl,
    attachments: attachments,
    createdAt: createdAt,
  );
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

DateTime _parseDate(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
  return DateTime.now();
}
