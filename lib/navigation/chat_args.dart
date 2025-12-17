import '../models/public_user_profile.dart';

/// Argumentos para la navegación a ChatScreen
class ChatArgs {
  /// ID del otro usuario
  final String otherUserId;

  /// ID del chat (opcional, se puede crear si no existe)
  final String? chatId;

  /// Perfil del otro usuario precargado (opcional)
  final PublicUserProfile? prefetchedUser;

  const ChatArgs({
    required this.otherUserId,
    this.chatId,
    this.prefetchedUser,
  });
}

