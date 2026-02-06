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

  /// Crear intercambio: POST /api/exchanges
  static const String exchanges = '$apiBase/exchanges';

  /// Detalle y confirmar: GET/POST /api/exchanges/{id}
  static String exchangeDetail(String id) => '$apiBase/exchanges/$id';
  static String exchangeConfirm(String id) => '$apiBase/exchanges/$id/confirm';
  static String exchangeJoin(String id) => '$apiBase/exchanges/$id/join';
  static String exchangeLeave(String id) => '$apiBase/exchanges/$id/leave';

  // TODO(BE): POST /api/chats o GET /api/chats/with/{userId} - Obtener o crear chatId
  // static const String chats = '$apiBase/chats';

  // TODO(BE): GET /api/chats/{chatId}/messages?page=&pageSize= - Listar mensajes (paginado)
  // TODO(BE): POST /api/chats/{chatId}/messages - Enviar mensaje
  // TODO(BE): WebSocket /ws/chats/{chatId} o SSE para mensajes en tiempo real
}
