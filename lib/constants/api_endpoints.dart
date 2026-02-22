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

  /// Estadísticas del usuario autenticado (para Home)
  static const String userStats = '$apiBase/users/me/stats';

  /// Endpoint de perfil
  static const String profile = '$apiBase/profile';

  // TODO(BE): PUT /api/profile - Actualizar perfil (name, description, nativeLanguage, avatar)
  // TODO(BE): DELETE /api/profile - Eliminar cuenta del usuario

  // --- Endpoints de Usuarios (Find) ---

  /// Búsqueda de usuarios: GET /api/users/search?nativeLang=&learningLang=&page=&size=
  static const String usersSearch = '$apiBase/users/search';

  /// Perfil público: GET /api/users/{id}/profile. PUT reutiliza esta ruta.
  static String userProfile(String id) => '$apiBase/users/$id/profile';

  /// POST /api/users/{id}/languages/learn — añadir idioma de aprendizaje
  static String userLanguagesLearn(String id) => '$apiBase/users/$id/languages/learn';

  /// PUT /api/users/{id}/languages/native — actualizar idioma nativo
  static String userLanguagesNative(String id) => '$apiBase/users/$id/languages/native';

  /// DELETE /api/users/{id}/languages/learn/by-code/{code} — eliminar idioma por código
  static String userLanguagesLearnByCode(String id, String code) =>
      '$apiBase/users/$id/languages/learn/by-code/$code';

  /// PUT /api/users/{id}/languages/learn/by-code/{code} — actualizar nivel por código
  static String userLanguagesLevelByCode(String id, String code) =>
      '$apiBase/users/$id/languages/learn/by-code/$code';

  /// POST /api/users/{id}/profile/picture — subir foto de perfil
  static String userProfilePicture(String id) => '$apiBase/users/$id/profile/picture';

  /// GET /api/languages — listado de idiomas (id, name, isoCode) para usar IDs reales al añadir
  static const String languages = '$apiBase/languages';

  // --- Endpoints de Chat ---

  // --- Endpoints de Intercambios ---

  /// Intercambios del usuario: GET /api/exchanges/joined
  static const String exchangesJoined = '$apiBase/exchanges/joined';

  /// Intercambios públicos: GET /api/exchanges/public
  static const String exchangesPublic = '$apiBase/exchanges/public';

  /// Unirse a intercambio privado con contraseña: POST /api/exchanges/{id}/join-with-password
  static String exchangeJoinWithPassword(String id) => '$apiBase/exchanges/$id/join-with-password';

  /// Crear intercambio: POST /api/exchanges
  static const String exchanges = '$apiBase/exchanges';

  /// Detalle y confirmar: GET/POST /api/exchanges/{id}
  static String exchangeDetail(String id) => '$apiBase/exchanges/$id';
  static String exchangeConfirm(String id) => '$apiBase/exchanges/$id/confirm';
  static String exchangeJoin(String id) => '$apiBase/exchanges/$id/join';
  static String exchangeLeave(String id) => '$apiBase/exchanges/$id/leave';

  /// Solicitud de unión (usuario no elegible): POST /api/exchanges/{id}/join-request
  static String exchangeJoinRequest(String id) => '$apiBase/exchanges/$id/join-request';
  /// Listar solicitudes pendientes (solo creador): GET /api/exchanges/{id}/join-requests
  static String exchangeJoinRequests(String id) => '$apiBase/exchanges/$id/join-requests';
  /// Aceptar solicitud: POST /api/exchanges/{id}/join-requests/{requestId}/accept
  static String exchangeJoinRequestAccept(String exchangeId, String requestId) =>
      '$apiBase/exchanges/$exchangeId/join-requests/$requestId/accept';
  /// Rechazar solicitud: POST /api/exchanges/{id}/join-requests/{requestId}/reject
  static String exchangeJoinRequestReject(String exchangeId, String requestId) =>
      '$apiBase/exchanges/$exchangeId/join-requests/$requestId/reject';

  /// Chat del intercambio: GET /api/exchanges/{id}/messages, POST /api/exchanges/{id}/messages
  static String exchangeMessages(String exchangeId) => '$apiBase/exchanges/$exchangeId/messages';

  // --- Chat 1:1 entre usuarios ---

  /// Obtener/crear chatId: GET /api/chats/with/{userId}
  static String chatsWithUser(String userId) => '$apiBase/chats/with/$userId';

  /// Mensajes del chat 1:1: GET/POST /api/chats/{chatId}/messages
  static String chatMessages(String chatId) => '$apiBase/chats/$chatId/messages';

  // --- Notificaciones ---

  /// Lista notificaciones: GET /api/notifications?unreadOnly=&page=&size=
  static const String notifications = '$apiBase/notifications';

  /// Contador no leídas: GET /api/notifications/unread-count
  static const String notificationsUnreadCount = '$apiBase/notifications/unread-count';

  /// Marcar como leída: PUT /api/notifications/{id}/read
  static String notificationMarkRead(String id) => '$apiBase/notifications/$id/read';

  /// Marcar varias como leídas: POST /api/notifications/read
  static const String notificationsMarkRead = '$apiBase/notifications/read';
}
