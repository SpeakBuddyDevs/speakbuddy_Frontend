/// Rutas nombradas de la aplicación
/// 
/// Este archivo centraliza todas las rutas de navegación para evitar
/// errores tipográficos y facilitar el mantenimiento.
class AppRoutes {
  /// Ruta raíz (pantalla de login)
  static const String home = '/';

  /// Ruta de registro
  static const String register = '/register';

  /// Ruta de login
  static const String login = '/login';

  /// Ruta principal con navegación por tabs (después del login)
  static const String main = '/main';

  /// Ruta de perfil público de usuario
  static const String publicProfile = '/public-profile';

  /// Ruta de chat con usuario
  static const String chat = '/chat';

  /// Ruta de intercambios públicos
  static const String publicExchanges = '/public-exchanges';

  /// Ruta de creación de intercambio
  static const String createExchange = '/create-exchange';

  /// Ruta de historial de intercambios completados
  static const String exchangeHistory = '/exchange-history';

  /// Ruta de notificaciones
  static const String notifications = '/notifications';

  /// Ruta de valoración de participantes post-intercambio
  static const String rateParticipants = '/rate-participants';

  /// Ruta de temas favoritos generados por IA
  static const String favoriteTopics = '/favorite-topics';
}

