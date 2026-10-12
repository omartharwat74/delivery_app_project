import 'package:equatable/equatable.dart';
import 'package:delivery_app_project/features/support/domain/entities/support_conversation.dart';

class SupportState extends Equatable {
  const SupportState({
    this.isLoading = false,
    this.isSending = false,
    this.conversation,
    this.messages = const [],
    this.lastMessageId = 0,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSending;
  final SupportConversation? conversation;
  final List<SupportChatMsg> messages;
  final int lastMessageId;
  final String? errorMessage;

  bool get hasConversation => conversation != null;

  SupportState copyWith({
    bool? isLoading,
    bool? isSending,
    SupportConversation? conversation,
    bool clearConversation = false,
    List<SupportChatMsg>? messages,
    int? lastMessageId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupportState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      conversation: clearConversation
          ? null
          : conversation ?? this.conversation,
      messages: messages ?? this.messages,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSending,
    conversation,
    messages,
    lastMessageId,
    errorMessage,
  ];
}
