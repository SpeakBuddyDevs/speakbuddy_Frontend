import '../models/chat_message.dart';

/// Abstracción para el repositorio de chat
/// 
/// BACKEND: Crear ApiChatRepository que implemente esta interfaz.
/// Sustituir FakeChatRepository por ApiChatRepository en las pantallas.
/// 
/// Endpoints requeridos:
/// - POST /api/chats o GET /api/chats/with/{userId} → { chatId }
/// - GET /api/chats/{chatId}/messages?page=&pageSize= → { messages: [], hasMore: bool }
/// - POST /api/chats/{chatId}/messages → { message }
/// - WebSocket /ws/chats/{chatId} para tiempo real (o SSE/Firebase)
abstract class ChatRepository {
  /// Obtiene o crea un chatId para la conversación con otro usuario
  /// BACKEND: POST /api/chats { otherUserId } o GET /api/chats/with/{otherUserId}
  Future<String> getOrCreateChatId({required String otherUserId});

  /// Obtiene o crea un chatId para un intercambio grupal
  /// BACKEND: POST /api/chats/exchange { exchangeId } o GET /api/chats/exchange/{exchangeId}
  Future<String> getOrCreateExchangeChatId({required String exchangeId});

  /// Stream de mensajes para un chat específico
  /// BACKEND: Implementar con WebSocket para tiempo real
  /// TODO(FE): Cambiar a WebSocket cuando BE lo implemente, mapear eventos "message_created"
  Stream<List<ChatMessage>> watchMessages({required String chatId});

  /// Envía un mensaje a un chat
  /// BACKEND: POST /api/chats/{chatId}/messages { text }
  /// TODO(BE): Devolver el mensaje creado con id y createdAt del servidor
  Future<void> sendMessage({required String chatId, required String text});
}

