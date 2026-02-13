import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../models/chat_message.dart';
import '../services/auth_service.dart';
import 'chat_repository.dart';
import 'fake_chat_repository.dart';

/// Implementación que usa la API para chat de intercambios y Fake para chat 1:1.
/// Chat de intercambio: chatId con formato "exchange_{exchangeId}".
class ApiChatRepository implements ChatRepository {
  static const String _exchangePrefix = 'exchange_';

  final _authService = AuthService();
  final FakeChatRepository _fake = FakeChatRepository();

  bool _isExchangeChat(String chatId) => chatId.startsWith(_exchangePrefix);

  String _exchangeIdFromChatId(String chatId) =>
      chatId.replaceFirst(_exchangePrefix, '');

  @override
  Future<String> getOrCreateChatId({required String otherUserId}) async {
    return _fake.getOrCreateChatId(otherUserId: otherUserId);
  }

  @override
  Future<String> getOrCreateExchangeChatId({required String exchangeId}) async {
    return '$_exchangePrefix$exchangeId';
  }

  @override
  Stream<List<ChatMessage>> watchMessages({required String chatId}) {
    if (!_isExchangeChat(chatId)) {
      return _fake.watchMessages(chatId: chatId);
    }

    final exchangeId = _exchangeIdFromChatId(chatId);
    final controller = StreamController<List<ChatMessage>>.broadcast();
    Timer? pollTimer;

    Future<void> fetchAndEmit() async {
      try {
        final list = await _fetchExchangeMessages(exchangeId);
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

  Future<List<ChatMessage>> _fetchExchangeMessages(String exchangeId) async {
    final headers = await _authService.headersWithAuth();
    final uri = Uri.parse(ApiEndpoints.exchangeMessages(exchangeId));
    final response = await http.get(uri, headers: headers);

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
    if (!_isExchangeChat(chatId)) {
      return _fake.sendMessage(chatId: chatId, text: text);
    }

    final exchangeId = _exchangeIdFromChatId(chatId);
    final headers = await _authService.headersWithAuth();
    headers['Content-Type'] = 'application/json';

    final uri = Uri.parse(ApiEndpoints.exchangeMessages(exchangeId));
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'content': text}),
    );

    if (response.statusCode != 200) {
      final body = response.body;
      throw Exception('Error ${response.statusCode}: $body');
    }
  }
}
