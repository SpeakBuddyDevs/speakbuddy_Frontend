import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../models/chat_message.dart';
import 'base_api_repository.dart';
import 'chat_repository.dart';

/// Implementación que usa la API para chat de intercambios y chat 1:1.
/// Chat de intercambio: chatId con formato "exchange_{exchangeId}".
/// Chat 1:1: chatId con formato "chat_{minUserId}_{maxUserId}".
class ApiChatRepository extends BaseApiRepository implements ChatRepository {
  static const String _exchangePrefix = 'exchange_';
  static const String _directChatPrefix = 'chat_';

  bool _isExchangeChat(String chatId) => chatId.startsWith(_exchangePrefix);

  bool _isDirectChat(String chatId) => chatId.startsWith(_directChatPrefix);

  String _exchangeIdFromChatId(String chatId) =>
      chatId.replaceFirst(_exchangePrefix, '');

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
    Timer? pollTimer;

    Future<void> fetchAndEmit() async {
      try {
        List<ChatMessage> list;
        if (_isExchangeChat(chatId)) {
          final exchangeId = _exchangeIdFromChatId(chatId);
          list = await _fetchExchangeMessages(exchangeId);
        } else if (_isDirectChat(chatId)) {
          list = await _fetchDirectChatMessages(chatId);
        } else {
          list = [];
        }
        if (!controller.isClosed) {
          controller.add(list);
        }
      } catch (e) {
        debugPrint('ApiChatRepository watchMessages error: $e');
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    fetchAndEmit().then((_) {
      pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => fetchAndEmit());
    });

    controller.onCancel = () {
      pollTimer?.cancel();
    };

    return controller.stream;
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
    String uri;
    if (_isExchangeChat(chatId)) {
      final exchangeId = _exchangeIdFromChatId(chatId);
      uri = ApiEndpoints.exchangeMessages(exchangeId);
    } else if (_isDirectChat(chatId)) {
      uri = ApiEndpoints.chatMessages(chatId);
    } else {
      throw Exception('chatId inválido: $chatId');
    }

    final auth = await buildAuthContext(extraHeaders: {
      'Content-Type': 'application/json',
    });

    final response = await http.post(
      Uri.parse(uri),
      headers: auth.headers,
      body: jsonEncode({'content': text}),
    );

    if (response.statusCode != 200) {
      final body = response.body;
      throw Exception('Error ${response.statusCode}: $body');
    }
  }
}
