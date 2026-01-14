import '../models/public_user_profile.dart';

/// Argumentos para la navegación a PublicProfileScreen
class PublicProfileArgs {
  /// ID del usuario (siempre requerido)
  final String userId;

  /// Perfil precargado (opcional, para evitar carga adicional)
  final PublicUserProfile? prefetched;

  const PublicProfileArgs({
    required this.userId,
    this.prefetched,
  });
}

