/// Represents the active support conversation returned by `GET /api/delivery/v1/support`.
class SupportConversation {
  const SupportConversation({
    required this.id,
    required this.status,
    required this.messages,
  });

  final int id;
  final String status;
  final List<SupportChatMsg> messages;
}

/// A single chat message from the support conversation.
class SupportChatMsg {
  const SupportChatMsg({
    required this.id,
    required this.body,
    required this.senderType,
    required this.imageUrl,
    required this.attachments,
    required this.createdAt,
  });

  final int id;
  final String? body;

  /// 'delivery' (mine) | 'admin'
  final String senderType;
  final String? imageUrl;
  final List<String> attachments;
  final DateTime createdAt;

  /// true when the message was sent by the delivery driver himself.
  bool get isMine => senderType == 'delivery';
}
