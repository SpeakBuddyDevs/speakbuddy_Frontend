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

  // TODO(BE): Implementar POST /api/auth/logout para invalidar token en servidor
  // static const String logout = '$authBase/logout';

  // TODO(BE): Implementar POST /api/auth/refresh para renovar accessToken
  // static const String refresh = '$authBase/refresh';

  // --- Endpoints de Perfil ---

  /// Obtener usuario actual
  static const String me = '$apiBase/users/me';

  /// Endpoint de perfil
  static const String profile = '$apiBase/profile';

  // TODO(BE): PUT /api/profile - Actualizar perfil (name, description, nativeLanguage, avatar)
  // TODO(BE): DELETE /api/profile - Eliminar cuenta del usuario

  // --- Endpoints de Usuarios (Find) ---

  // TODO(BE): GET /api/users/search?q=&page=&pageSize=&online=&pro=&minRating=&nativeLang=&targetLang=&country=
  // static const String usersSearch = '$apiBase/users/search';

  // TODO(BE): GET /api/users/{id} - Perfil público de un usuario
  // static const String user = '$apiBase/users'; // + /{id}

  // --- Endpoints de Chat ---

  // TODO(BE): POST /api/chats o GET /api/chats/with/{userId} - Obtener o crear chatId
  // static const String chats = '$apiBase/chats';

  // TODO(BE): GET /api/chats/{chatId}/messages?page=&pageSize= - Listar mensajes (paginado)
  // TODO(BE): POST /api/chats/{chatId}/messages - Enviar mensaje
  // TODO(BE): WebSocket /ws/chats/{chatId} o SSE para mensajes en tiempo real
}
