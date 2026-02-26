import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../models/chat_message.dart';
import '../services/current_user_service.dart';
import '../services/websocket_chat_service.dart';
import 'base_api_repository.dart';
import 'chat_repository.dart';

/// Implementación que usa la API para chat de intercambios y chat 1:1.
/// Chat de intercambio: chatId con formato "exchange_{exchangeId}" (REST + polling).
/// Chat 1:1: chatId con formato "chat_{minUserId}_{maxUserId}" (WebSocket en tiempo real).
class ApiChatRepository extends BaseApiRepository implements ChatRepository {
  static const String _exchangePrefix = 'exchange_';
  static const String _directChatPrefix = 'chat_';

  final _wsService = WebSocketChatService();

  /// Controllers activos por chatId (solo para chat 1:1) para optimistic updates.
  final _directChatControllers = <String, StreamController<List<ChatMessage>>>{};
  final _directChatMessages = <String, List<ChatMessage>>{};

  bool _isExchangeChat(String chatId) => chatId.startsWith(_exchangePrefix);

  bool _isDirectChat(String chatId) => chatId.startsWith(_directChatPrefix);

  String _exchangeIdFromChatId(String chatId) =>
      chatId.replaceFirst(_exchangePrefix, '');

  int? _recipientIdFromChatId(String chatId) {
    if (!_isDirectChat(chatId)) return null;
    final parts = chatId.replaceFirst(_directChatPrefix, '').split('_');
    if (parts.length != 2) return null;
    final me = CurrentUserService().getUserId();
    if (me == null) return null;
    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    if (a == null || b == null) return null;
    return int.parse(me) == a ? b : a;
  }

  @override
  Future<String> getOrCreateChatId({required String otherUserId}) async {
    final auth = await buildAuthContext();
    final uri = Uri.parse(ApiEndpoints.chatsWithUser(otherUserId));
    final response = await http.get(uri, headers: auth.headers);

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>?;
    final chatId = data?['chatId']?.toString();
    if (chatId == null || chatId.isEmpty) {
      throw Exception('Respuesta inválida: chatId no encontrado');
    }
    return chatId;
  }

  @override
  Future<String> getOrCreateExchangeChatId({required String exchangeId}) async {
    return '$_exchangePrefix$exchangeId';
  }

  @override
  Stream<List<ChatMessage>> watchMessages({required String chatId}) {
    final controller = StreamController<List<ChatMessage>>.broadcast();

    if (_isExchangeChat(chatId)) {
      _watchExchangeMessages(chatId, controller);
    } else if (_isDirectChat(chatId)) {
      _watchDirectChatMessages(chatId, controller);
    } else {
      controller.add([]);
    }

    return controller.stream;
  }

  /// Chat de intercambio: REST + polling (no hay WebSocket en backend).
  void _watchExchangeMessages(String chatId, StreamController<List<ChatMessage>> controller) {
    Timer? pollTimer;

    Future<void> fetchAndEmit() async {
      try {
        final exchangeId = _exchangeIdFromChatId(chatId);
        final list = await _fetchExchangeMessages(exchangeId);
        if (!controller.isClosed) controller.add(list);
      } catch (e) {
        debugPrint('ApiChatRepository watchMessages error: $e');
        if (!controller.isClosed) controller.addError(e);
      }
    }

    fetchAndEmit().then((_) {
      pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => fetchAndEmit());
    });

    controller.onCancel = () {
      pollTimer?.cancel();
    };
  }

  /// Chat 1:1: REST (carga inicial) + WebSocket (tiempo real).
  void _watchDirectChatMessages(String chatId, StreamController<List<ChatMessage>> controller) {
    StreamSubscription<ChatMessage>? wsSub;

    Future<void> run() async {
      try {
        List<ChatMessage> initial = await _fetchDirectChatMessages(chatId);
        if (controller.isClosed) return;
        _directChatMessages[chatId] = initial;
        _directChatControllers[chatId] = controller;
        controller.add(initial);

        await _wsService.connect();

        if (controller.isClosed) return;
        wsSub = _wsService.incomingMessages
            .where((m) => m.chatId == chatId)
            .listen((msg) {
          if (controller.isClosed) return;
          final list = _directChatMessages[chatId] ?? [];
          if (list.any((m) => m.id == msg.id)) return;
          final updated = [...list, msg];
          _directChatMessages[chatId] = updated;
          controller.add(updated);
        });
      } catch (e) {
        debugPrint('ApiChatRepository watchDirectChat error: $e');
        if (!controller.isClosed) controller.addError(e);
      }
    }

    run();

    controller.onCancel = () {
      wsSub?.cancel();
      _directChatControllers.remove(chatId);
      _directChatMessages.remove(chatId);
    };
  }

  Future<List<ChatMessage>> _fetchDirectChatMessages(String chatId) async {
    final auth = await buildAuthContext();
    final uri = Uri.parse(ApiEndpoints.chatMessages(chatId));
    final response = await http.get(uri, headers: auth.headers);

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>?;
    if (list == null) return [];

    return list
        .map((e) => _directMessageFromJson(e as Map<String, dynamic>, chatId))
        .toList();
  }

  ChatMessage _directMessageFromJson(Map<String, dynamic> json, String chatId) {
    final id = (json['id'] ?? '').toString();
    final content = (json['content'] ?? '').toString();
    final senderId = (json['senderId'] is int)
        ? (json['senderId'] as int).toString()
        : (json['senderId'] ?? '').toString();
    final senderName = json['senderName']?.toString();
    final timestamp = json['timestamp'];
    final createdAt = _parseDateTime(timestamp) ?? DateTime.now();

    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      text: content,
      createdAt: createdAt,
      senderName: senderName,
    );
  }

  Future<List<ChatMessage>> _fetchExchangeMessages(String exchangeId) async {
    final auth = await buildAuthContext();
    final uri = Uri.parse(ApiEndpoints.exchangeMessages(exchangeId));
    final response = await http.get(uri, headers: auth.headers);

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>?;
    if (list == null) return [];

    return list
        .map((e) => _messageFromJson(e as Map<String, dynamic>, exchangeId))
        .toList();
  }

  ChatMessage _messageFromJson(Map<String, dynamic> json, String exchangeId) {
    final chatId = '$_exchangePrefix$exchangeId';
    final id = (json['id'] ?? '').toString();
    final content = (json['content'] ?? '').toString();
    final senderId = (json['senderId'] is int)
        ? (json['senderId'] as int).toString()
        : (json['senderId'] ?? '').toString();
    final senderName = json['senderName']?.toString();
    final timestamp = json['timestamp'];
    final createdAt = _parseDateTime(timestamp) ?? DateTime.now();

    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      text: content,
      createdAt: createdAt,
      senderName: senderName,
    );
  }

  DateTime? _parseDateTime(dynamic raw) {
    if (raw == null) return null;

    if (raw is String) {
      return DateTime.tryParse(raw);
    }

    // Soporta formato array de LocalDateTime serializado por backend Java:
    // [year, month, day, hour, minute, second, nano?]
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

  @override
  Future<void> sendMessage({required String chatId, required String text}) async {
    if (_isExchangeChat(chatId)) {
      final exchangeId = _exchangeIdFromChatId(chatId);
      final auth = await buildAuthContext(extraHeaders: {
        'Content-Type': 'application/json',
      });
      final response = await http.post(
        Uri.parse(ApiEndpoints.exchangeMessages(exchangeId)),
        headers: auth.headers,
        body: jsonEncode({'content': text}),
      );
      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
      return;
    }

    if (_isDirectChat(chatId)) {
      final recipientId = _recipientIdFromChatId(chatId);
      if (recipientId == null) {
        throw Exception('No se pudo determinar el destinatario');
      }

      final currentUserId = CurrentUserService().getUserId();
      if (currentUserId == null) throw Exception('Usuario no identificado');

      final optimistic = ChatMessage(
        id: 'opt_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        senderId: currentUserId,
        text: text,
        createdAt: DateTime.now(),
        senderName: null,
      );

      final ctrl = _directChatControllers[chatId];
      if (ctrl != null && !ctrl.isClosed) {
        final list = _directChatMessages[chatId] ?? [];
        final updated = [...list, optimistic];
        _directChatMessages[chatId] = updated;
        ctrl.add(updated);
      }

      if (_wsService.isConnected) {
        _wsService.sendMessage(recipientId: recipientId, content: text);
        return;
      }

      final auth = await buildAuthContext(extraHeaders: {
        'Content-Type': 'application/json',
      });
      final response = await http.post(
        Uri.parse(ApiEndpoints.chatMessages(chatId)),
        headers: auth.headers,
        body: jsonEncode({'content': text}),
      );
      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    }

    throw Exception('chatId inválido: $chatId');
  }
}
