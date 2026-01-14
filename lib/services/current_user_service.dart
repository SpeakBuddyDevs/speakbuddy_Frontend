/// Servicio temporal para obtener datos del usuario actual.
///
/// BACKEND: Este servicio debe ser sustituido por una implementación
/// que obtenga los datos del usuario autenticado desde el backend.
///
/// TODO(BE): Exponer en /me o /api/profile los siguientes campos:
///   - displayName: String (nombre del usuario)
///   - level: int (nivel actual del usuario)
///   - progressToNextLevel: double (0.0-1.0, progreso hacia el siguiente nivel)
///   - isPro: bool (si el usuario tiene suscripción Pro)
///
/// TODO(FE): Reemplazar este mock por implementación conectada a:
///   - UsersRepository o AuthService
///   - Cachear datos en memoria/almacenamiento local
///   - Actualizar cuando el usuario cambie de nivel o progreso
class CurrentUserService {
  // Singleton pattern para acceso global
  static final CurrentUserService _instance = CurrentUserService._internal();
  factory CurrentUserService() => _instance;
  CurrentUserService._internal();

  /// Obtiene el nombre de visualización del usuario actual.
  ///
  /// BACKEND: Debe provenir del endpoint /me o /api/profile del usuario autenticado.
  String getDisplayName() {
    // TODO(BE): Obtener desde backend
    // TODO(FE): Sustituir por llamada al repositorio real
    return 'SpeakBuddy';
  }

  /// Obtiene el nivel actual del usuario.
  ///
  /// BACKEND: Debe provenir del endpoint /me o /api/profile.
  int getLevel() {
    // TODO(BE): Obtener desde backend
    // TODO(FE): Sustituir por llamada al repositorio real
    return 5;
  }

  /// Obtiene el progreso hacia el siguiente nivel (0.0-1.0).
  ///
  /// BACKEND: Debe ser calculado o enviado desde el backend.
  /// El backend puede enviar:
  ///   - progressToNextLevel directamente (0.0-1.0)
  ///   - O xp/currentXp/nextXp para calcularlo en el frontend
  double getProgressToNextLevel() {
    // TODO(BE): Obtener desde backend o calcular desde xp/currentXp/nextXp
    // TODO(FE): Sustituir por llamada al repositorio real
    return 0.40; // 40% de progreso
  }

  /// Indica si el usuario tiene suscripción Pro.
  ///
  /// BACKEND: Debe provenir del endpoint /me o /api/profile.
  bool isPro() {
    // TODO(BE): Obtener desde backend
    // TODO(FE): Sustituir por llamada al repositorio real
    return true;
  }
}

