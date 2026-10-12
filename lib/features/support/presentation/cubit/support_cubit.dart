import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app_project/core/constants/api_constants.dart';
import 'package:delivery_app_project/features/support/data/models/support_conversation_dto.dart';
import 'package:delivery_app_project/features/support/domain/entities/support_conversation.dart';
import 'package:delivery_app_project/features/support/presentation/cubit/support_state.dart';

export 'support_state.dart';

/// Cubit that manages the Delivery app's support chat.
///
/// Architecture (matches SUPPORT_CHAT_CLIENT.md):
///   • MySQL (Laravel REST API) is the source of truth for messages.
///   • Firebase RTDB is only a "bell" signal (`last_message_id` changed).
///   • Client listens on `support_realtime/conversations/{conversationId}`,
///     then fetches real content from REST.
///
/// Base path: `https://mycar.msarweb.net/api/delivery/v1`
/// Endpoints used:
///   GET  /support                        → load screen
///   POST /support/messages  (multipart)  → send message
///   GET  /support/messages?after_id={n}  → fetch new messages after bell
class SupportCubit extends Cubit<SupportState> {
  SupportCubit({required Dio dio}) : _dio = dio, super(const SupportState());

  final Dio _dio;

  StreamSubscription<DatabaseEvent>? _firebaseSub;
  int? _listeningConversationId;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Loads the active support conversation from `GET /support`.
  /// If no conversation exists, clears state and stops any Firebase listener.
  Future<void> loadInitialSupport() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final response = await _dio.get<dynamic>(ApiConstants.support);
      final data = _extractData(response.data);

      if (data == null) {
        // No active conversation — show empty chat ready for first message
        emit(
          const SupportState(isLoading: false, messages: [], lastMessageId: 0),
        );
        _stopFirebaseListener();
        return;
      }

      final dto = SupportConversationDto.fromJson(data);
      final conversation = dto.toEntity();
      final msgs = List<SupportChatMsg>.from(conversation.messages);
      msgs.sort((a, b) => a.id.compareTo(b.id));

      final maxId = _maxId(msgs);

      emit(
        state.copyWith(
          isLoading: false,
          conversation: conversation,
          messages: msgs,
          lastMessageId: maxId,
          clearError: true,
        ),
      );

      _startFirebaseListener(conversation.id);
    } on DioException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(isLoading: false, errorMessage: _extractDioError(e)),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    }
  }

  /// Sends a message via `POST /support/messages` (multipart).
  /// Instantly appends the returned message and updates [lastMessageId].
  Future<void> sendMessage({String? text, File? image}) async {
    if (isClosed) return;
    if ((text == null || text.trim().isEmpty) && image == null) return;

    emit(state.copyWith(isSending: true, clearError: true));
    try {
      final formData = FormData.fromMap({
        if (text != null && text.trim().isNotEmpty) 'body': text.trim(),
        if (image != null)
          'attachment': await MultipartFile.fromFile(
            image.path,
            filename: 'image.jpg',
          ),
      });

      final response = await _dio.post<dynamic>(
        ApiConstants.supportMessages,
        data: formData,
      );

      final responseData = response.data;
      final msgData = _extractMessageFromResponse(responseData);
      final convData = _extractConversationFromResponse(responseData);

      // Parse the returned message
      SupportChatMsg? newMsg;
      if (msgData != null) {
        newMsg = SupportChatMsgDto.fromJson(msgData).toEntity();
      }

      // Check if a brand-new conversation was created
      int? newConvId;
      SupportConversation? updatedConv = state.conversation;
      if (convData != null) {
        final convDto = SupportConversationDto.fromJson(convData);
        newConvId = convDto.id;
        updatedConv = convDto.toEntity();
      }

      final updatedMessages = [...state.messages, ?newMsg];
      final newLastId = newMsg != null
          ? (newMsg.id > state.lastMessageId ? newMsg.id : state.lastMessageId)
          : state.lastMessageId;

      emit(
        state.copyWith(
          isSending: false,
          conversation: updatedConv,
          messages: updatedMessages,
          lastMessageId: newLastId,
          clearError: true,
        ),
      );

      // Restart Firebase listener if a new conversation was created
      if (newConvId != null && newConvId != _listeningConversationId) {
        _startFirebaseListener(newConvId);
      } else if (updatedConv != null && _listeningConversationId == null) {
        _startFirebaseListener(updatedConv.id);
      }
    } on DioException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(isSending: false, errorMessage: _extractDioError(e)),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isSending: false, errorMessage: e.toString()));
      }
    }
  }

  /// Fetches messages newer than [afterId] from `GET /support/messages?after_id=`.
  Future<void> fetchNewMessages(int afterId) async {
    if (isClosed) return;
    try {
      final response = await _dio.get<dynamic>(
        '${ApiConstants.supportMessages}?after_id=$afterId',
      );
      final rawData = response.data;
      if (rawData == null) return;

      List<dynamic> rawList = [];
      if (rawData is Map<String, dynamic>) {
        final inner = rawData['data'];
        if (inner is List) {
          rawList = inner;
        } else if (inner is Map<String, dynamic>) {
          if (inner.containsKey('items') && inner['items'] is List) {
            rawList = inner['items'] as List<dynamic>;
          } else if (inner.containsKey('messages')) {
            if (inner['messages'] is List) {
              rawList = inner['messages'] as List<dynamic>;
            } else if (inner['messages'] is Map &&
                (inner['messages'] as Map)['items'] is List) {
              rawList = (inner['messages'] as Map)['items'] as List<dynamic>;
            }
          }
        }
      }

      final newMsgs = rawList
          .whereType<Map<String, dynamic>>()
          .map(SupportChatMsgDto.fromJson)
          .map((d) => d.toEntity())
          .where((m) => m.id > state.lastMessageId)
          .toList();

      if (newMsgs.isEmpty || isClosed) return;

      final updatedMessages = List<SupportChatMsg>.from(state.messages)
        ..addAll(newMsgs);
      updatedMessages.sort((a, b) => a.id.compareTo(b.id));

      final newLastId = updatedMessages.last.id;
      emit(state.copyWith(messages: updatedMessages, lastMessageId: newLastId));
    } catch (e) {
      debugPrint('[SupportCubit] fetchNewMessages error: $e');
    }
  }

  /// Cleans up the Firebase listener. Must be called from the screen's dispose().
  void cleanupListeners() {
    _stopFirebaseListener();
  }

  // ── Firebase RTDB "Bell" Listener ──────────────────────────────────────────

  void _startFirebaseListener(int conversationId) {
    if (_listeningConversationId == conversationId) return;
    _stopFirebaseListener();

    _listeningConversationId = conversationId;

    const String dbUrl =
        'https://lababk-10014-default-rtdb.europe-west1.firebasedatabase.app';
    final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: dbUrl,
    );

    final ref = db.ref('support_realtime/conversations/$conversationId');

    _firebaseSub = ref.onValue.listen(
      (event) {
        if (isClosed) return;
        if (event.snapshot.value == null) return;

        int? remoteLastId;
        if (event.snapshot.value is Map) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          remoteLastId = _parseInt(data['last_message_id']);
        } else if (event.snapshot.value is int) {
          remoteLastId = event.snapshot.value as int;
        }

        // Ignore initial fire or stale signal
        if (remoteLastId != null && remoteLastId > state.lastMessageId) {
          fetchNewMessages(state.lastMessageId);
        }
      },
      onError: (Object e) {
        debugPrint('[SupportCubit] Firebase listener error: $e');
      },
    );
  }

  void _stopFirebaseListener() {
    _firebaseSub?.cancel();
    _firebaseSub = null;
    _listeningConversationId = null;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Extracts `data` field from standard API envelope `{ status, msg, data }`.
  Map<String, dynamic>? _extractData(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data == null) return null;
      if (data is Map<String, dynamic>) return data;
    }
    return null;
  }

  /// Extracts the `message` object from the POST /support/messages response.
  Map<String, dynamic>? _extractMessageFromResponse(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        final msg = data['message'];
        if (msg is Map<String, dynamic>) return msg;
      }
    }
    return null;
  }

  /// Extracts the `conversation` from the POST response (created when sending
  /// the first message after a ticket close or on a fresh session).
  Map<String, dynamic>? _extractConversationFromResponse(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        if (data.containsKey('conversation') &&
            data['conversation'] is Map<String, dynamic>) {
          return data['conversation'] as Map<String, dynamic>;
        }
      }
    }
    return null;
  }

  int _maxId(List<SupportChatMsg> msgs) {
    if (msgs.isEmpty) return 0;
    return msgs.map((m) => m.id).reduce((a, b) => a > b ? a : b);
  }

  String _extractDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return (data['message'] as String?) ??
          (data['msg'] as String?) ??
          (data['error'] as String?) ??
          e.message ??
          e.toString();
    }
    return e.message ?? e.toString();
  }

  @override
  Future<void> close() {
    _stopFirebaseListener();
    return super.close();
  }
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}
