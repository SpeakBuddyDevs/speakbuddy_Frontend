import 'dart:async';
import '../models/chat_message.dart';
import '../constants/app_constants.dart';
import 'chat_repository.dart';

/// Implementación fake del repositorio de chat para desarrollo
/// 
/// TODO(FE): Eliminar este archivo cuando exista ApiChatRepository
/// BACKEND: Sustituir por ApiChatRepository que consuma:
/// - GET/POST /api/chats/with/{userId} para obtener chatId
/// - GET /api/chats/{chatId}/messages (paginado, orden por createdAt DESC)
/// - POST /api/chats/{chatId}/messages para enviar
/// - WebSocket /ws/chats/{chatId} para watchMessages en tiempo real
class FakeChatRepository implements ChatRepository {
  /// Almacén de mensajes en memoria por chatId
  static final Map<String, List<ChatMessage>> _messages = {};

  /// Controllers para emitir actualizaciones de mensajes
  static final Map<String, StreamController<List<ChatMessage>>> _controllers = {};

  /// Mensajes iniciales mock para simular conversaciones existentes
  static final Map<String, List<String>> _initialMessages = {
    '1': ['¡Hola! ¿Cómo estás?', 'Me gustaría practicar español contigo'],
    '2': ['Hey! Ready to practice?', '¿Podemos hablar en español?'],
    '3': ['Bonjour! Je voudrais pratiquer', '¿Tienes tiempo para charlar?'],
    '4': ['Hallo! Ich lerne Englisch', 'Can we practice together?'],
  };

  @override
  Future<String> getOrCreateChatId({required String otherUserId}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Genera un chatId determinista basado en los dos usuarios
    final ids = [AppConstants.currentUserIdMock, otherUserId]..sort();
    final chatId = 'chat_${ids[0]}_${ids[1]}';
    
    // Inicializar mensajes si no existen
    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = _generateInitialMessages(chatId, otherUserId);
    }
    
    return chatId;
  }

  @override
  Stream<List<ChatMessage>> watchMessages({required String chatId}) {
    // Crear controller si no existe
    if (!_controllers.containsKey(chatId)) {
      _controllers[chatId] = StreamController<List<ChatMessage>>.broadcast();
    }
    
    // Emitir mensajes actuales
    Future.microtask(() {
      final messages = _messages[chatId] ?? [];
      _controllers[chatId]?.add(List.from(messages));
    });
    
    return _controllers[chatId]!.stream;
  }

  @override
  Future<void> sendMessage({required String chatId, required String text}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: AppConstants.currentUserIdMock,
      text: text,
      createdAt: DateTime.now(),
    );
    
    _messages[chatId] ??= [];
    _messages[chatId]!.add(message);
    
    // Notificar a los listeners
    _controllers[chatId]?.add(List.from(_messages[chatId]!));
  }

  /// Genera mensajes iniciales mock para un chat
  List<ChatMessage> _generateInitialMessages(String chatId, String otherUserId) {
    final messages = <ChatMessage>[];
    final initialTexts = _initialMessages[otherUserId] ?? ['¡Hola!', '¿Cómo estás?'];
    
    for (var i = 0; i < initialTexts.length; i++) {
      messages.add(ChatMessage(
        id: 'msg_initial_${i}_$chatId',
        chatId: chatId,
        senderId: otherUserId,
        text: initialTexts[i],
        createdAt: DateTime.now().subtract(Duration(minutes: (initialTexts.length - i) * 5)),
      ));
    }
    
    return messages;
  }
}

