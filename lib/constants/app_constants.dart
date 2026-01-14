/// Constantes de la aplicación
///
/// Este archivo centraliza constantes utilizadas en toda la aplicación,
/// como keys de storage, headers HTTP y otras configuraciones comunes.
class AppConstants {
  // --- Storage Keys ---

  /// Key para almacenar el token JWT en el almacenamiento seguro
  static const String jwtTokenKey = 'jwt_token';

  // TODO(BE): Añadir key para refresh token cuando se implemente
  // static const String refreshTokenKey = 'refresh_token';

  // --- HTTP Headers ---

  /// Headers estándar para peticiones JSON
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };

  // BACKEND: Para peticiones autenticadas, añadir header Authorization: Bearer <token>
  // TODO(FE): Crear helper que añada token automáticamente a jsonHeaders

  // --- Mock IDs (solo desarrollo, eliminar cuando haya backend) ---

  /// ID del usuario actual en modo mock
  /// TODO(FE): Eliminar cuando el userId real venga del token JWT decodificado o GET /api/auth/me
  static const String currentUserIdMock = 'current_user_001';
}

