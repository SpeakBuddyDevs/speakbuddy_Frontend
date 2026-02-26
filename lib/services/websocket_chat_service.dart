import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../constants/api_endpoints.dart';
import '../models/chat_message.dart';
import 'auth_service.dart';
import 'current_user_service.dart';

/// Servicio singleton para chat 1:1 en tiempo real vía WebSocket (STOMP + SockJS).
/// Mantiene una única conexión y emite mensajes entrantes por [incomingMessages].
class WebSocketChatService {
  WebSocketChatService._();
  static final WebSocketChatService _instance = WebSocketChatService._();
  factory WebSocketChatService() => _instance;

  StompClient? _client;
  final _incomingController = StreamController<ChatMessage>.broadcast();

  /// Stream de mensajes entrantes. Filtrar por chatId según corresponda.
  Stream<ChatMessage> get incomingMessages => _incomingController.stream;

  bool get isConnected => _client?.connected ?? false;

  /// Conecta al WebSocket si no está conectado. Usa el JWT de AuthService.
  Future<void> connect() async {
    if (isConnected) return;

    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      debugPrint('WebSocketChatService: No token, skip connect');
      return;
    }

    late StompClient client;
    client = StompClient(
      config: StompConfig.sockJS(
        url: ApiEndpoints.wsChatEndpoint,
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        reconnectDelay: const Duration(seconds: 3),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        onConnect: (frame) {
          debugPrint('WebSocketChatService: Connected');
          client.subscribe(
            destination: '/user/queue/messages',
            callback: (frame) {
              if (frame.body == null || frame.body!.isEmpty) return;
              try {
                final json = jsonDecode(frame.body!) as Map<String, dynamic>;
                final msg = _parseIncomingMessage(json);
                if (msg != null && !_incomingController.isClosed) {
                  _incomingController.add(msg);
                }
              } catch (e) {
                debugPrint('WebSocketChatService: Parse error $e');
              }
            },
          );
        },
        onStompError: (frame) {
          debugPrint('WebSocketChatService: STOMP error ${frame.body}');
        },
        onWebSocketError: (error) {
          debugPrint('WebSocketChatService: WS error $error');
        },
        onWebSocketDone: () {
          debugPrint('WebSocketChatService: Disconnected');
        },
      ),
    );

    _client = client;
    client.activate();
  }

  /// Envía un mensaje por WebSocket al destinatario.
  void sendMessage({required int recipientId, required String content}) {
    final c = _client;
    if (c == null || !c.connected) {
      throw StateError('WebSocket no conectado');
    }
    c.send(
      destination: '/app/chat',
      body: jsonEncode({'content': content, 'recipientId': recipientId}),
      headers: {'content-type': 'application/json'},
    );
  }

  /// Desconecta y libera recursos. Llamar al hacer logout.
  void disconnect() {
    _client?.deactivate();
    _client = null;
  }

  ChatMessage? _parseIncomingMessage(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    final content = (json['content'] ?? '').toString();
    final senderId = (json['senderId'] is int)
        ? (json['senderId'] as int).toString()
        : (json['senderId'] ?? '').toString();
    final senderName = json['senderName']?.toString();
    final timestamp = json['timestamp'];
    final createdAt = _parseTimestamp(timestamp);
    if (createdAt == null) return null;

    final currentUserId = CurrentUserService().getUserId();
    if (currentUserId == null) return null;

    final sender = int.parse(senderId);
    final me = int.parse(currentUserId);
    final minId = sender < me ? sender : me;
    final maxId = sender > me ? sender : me;
    final chatId = 'chat_${minId}_$maxId';

    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      text: content,
      createdAt: createdAt,
      senderName: senderName,
    );
  }

  DateTime? _parseTimestamp(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is List && raw.length >= 6) {
      final y = (raw[0] as num?)?.toInt();
      final m = (raw[1] as num?)?.toInt();
      final d = (raw[2] as num?)?.toInt();
      final h = (raw[3] as num?)?.toInt();
      final min = (raw[4] as num?)?.toInt();
      final sec = (raw[5] as num?)?.toInt();
      if (y == null || m == null || d == null || h == null || min == null || sec == null) {
        return null;
      }
      final nano = raw.length >= 7 ? (raw[6] as num?)?.toInt() ?? 0 : 0;
      final micro = (nano / 1000).floor();
      final milli = micro ~/ 1000;
      final microRemainder = micro % 1000;
      return DateTime(y, m, d, h, min, sec, milli, microRemainder);
    }
    return null;
  }

  void dispose() {
    disconnect();
    _incomingController.close();
  }
}
