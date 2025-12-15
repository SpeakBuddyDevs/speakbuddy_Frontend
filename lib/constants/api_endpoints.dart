/// Endpoints de la API del backend
///
/// Este archivo centraliza todas las URLs y endpoints de la API para facilitar
/// el mantenimiento y evitar errores tipográficos.
///
/// NOTA: En el futuro, la URL base podría leerse de variables de entorno
/// o configuración según el entorno (desarrollo/staging/producción).
class ApiEndpoints {
  /// URL base del servidor
  static const String baseUrl = 'http://10.0.2.2:8080';

  /// Base de la API
  static const String apiBase = '$baseUrl/api';

  /// Base de autenticación
  static const String authBase = '$apiBase/auth';

  // --- Endpoints de Autenticación ---

  /// Endpoint de login
  static const String login = '$authBase/login';

  /// Endpoint de registro
  static const String register = '$authBase/register';

  // --- Endpoints de Perfil (para uso futuro) ---

  /// Obtener usuario actual
  static const String me = '$apiBase/auth/me';

  /// Endpoint de perfil
  static const String profile = '$apiBase/profile';
}

