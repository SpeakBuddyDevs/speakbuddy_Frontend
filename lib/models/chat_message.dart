// BACKEND: Mapea mensajes de GET /api/chats/{chatId}/messages
// TODO(BE): Devolver createdAt en UTC ISO-8601 (ej: "2025-01-15T10:30:00Z")
// TODO(BE): El id debe ser estable (UUID o autoincrement), no generado en cliente
// TODO(FE): Implementar factory ChatMessage.fromJson(Map<String, dynamic>)
// Response esperado: { id, chatId, senderId, text, createdAt (ISO-8601) }

/// Modelo de mensaje de chat
class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  /// Verifica si el mensaje es del usuario actual
  bool isMine(String currentUserId) => senderId == currentUserId;
}

