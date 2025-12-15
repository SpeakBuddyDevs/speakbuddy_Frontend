/// Constantes de la aplicación
///
/// Este archivo centraliza constantes utilizadas en toda la aplicación,
/// como keys de storage, headers HTTP y otras configuraciones comunes.
class AppConstants {
  // --- Storage Keys ---

  /// Key para almacenar el token JWT en el almacenamiento seguro
  static const String jwtTokenKey = 'jwt_token';

  // --- HTTP Headers ---

  /// Headers estándar para peticiones JSON
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };
}

