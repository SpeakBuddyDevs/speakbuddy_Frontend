import '../models/user_profile.dart';
import '../repositories/api_users_repository.dart';

/// Servicio para obtener y cachear datos del usuario actual.
///
/// BACKEND: Obtiene los datos del usuario autenticado desde /api/users/me
/// a través de `ApiUsersRepository.getMyProfile()`.
///
/// Campos esperados:
///   - name: String (nombre del usuario)
///   - level: int (nivel actual del usuario)
///   - progressPct: double (0.0-1.0, progreso hacia el siguiente nivel)
///   - isPro: bool (si el usuario tiene suscripción Pro)
class CurrentUserService {
  // Singleton pattern para acceso global
  static final CurrentUserService _instance = CurrentUserService._internal();
  factory CurrentUserService() => _instance;
  CurrentUserService._internal();

  final ApiUsersRepository _usersRepository = ApiUsersRepository();

  UserProfile? _profile;
  bool _isLoading = false;

  /// Limpia el caché del perfil. Debe llamarse al cerrar sesión para que
  /// el siguiente usuario que inicie sesión vea sus datos en el header.
  void clearCache() {
    _profile = null;
    _isLoading = false;
  }

  /// Carga el perfil del usuario desde el backend si aún no está en memoria.
  ///
  /// Se llama de forma perezosa desde los getters y también puede
  /// invocarse explícitamente (por ejemplo en initState de pantallas).
  Future<void> preload() async {
    await _loadFromBackendIfNeeded();
  }

  Future<void> _loadFromBackendIfNeeded() async {
    if (_profile != null || _isLoading) return;
    _isLoading = true;
    try {
      final profile = await _usersRepository.getMyProfile();
      _profile = profile;
    } catch (_) {
      // En caso de error, se mantienen los valores por defecto.
    } finally {
      _isLoading = false;
    }
  }

  /// Obtiene el nombre de visualización del usuario actual.
  ///
  /// BACKEND: Debe provenir del endpoint /me o /api/profile del usuario autenticado.
  String getDisplayName() {
    // Dispara carga en segundo plano si aún no se ha hecho.
    _loadFromBackendIfNeeded();
    return _profile?.name ?? 'Usuario';
  }

  /// Obtiene el nivel actual del usuario.
  ///
  /// BACKEND: Debe provenir del endpoint /me o /api/profile.
  int getLevel() {
    _loadFromBackendIfNeeded();
    return _profile?.level ?? 1;
  }

  /// Obtiene el progreso hacia el siguiente nivel (0.0-1.0).
  ///
  /// BACKEND: Debe ser calculado o enviado desde el backend.
  /// El backend puede enviar:
  ///   - progressToNextLevel directamente (0.0-1.0)
  ///   - O xp/currentXp/nextXp para calcularlo en el frontend
  double getProgressToNextLevel() {
    _loadFromBackendIfNeeded();
    return _profile?.progressPct ?? 0.0;
  }

  /// Indica si el usuario tiene suscripción Pro.
  ///
  /// BACKEND: Debe provenir del endpoint /me o /api/profile.
  bool isPro() {
    _loadFromBackendIfNeeded();
    return _profile?.isPro ?? false;
  }

  /// Obtiene el ID del usuario actual (síncrono, devuelve null si no se ha cargado).
  String? getUserId() {
    _loadFromBackendIfNeeded();
    return _profile?.id;
  }

  /// Obtiene el ID del usuario actual, asegurándose de cargar el perfil primero.
  ///
  /// Usar este método cuando se necesita el ID con garantía de que estará disponible
  /// (por ejemplo en chat para saber qué mensajes son propios).
  Future<String?> getCurrentUserId() async {
    await _loadFromBackendIfNeeded();
    return _profile?.id;
  }

  /// Obtiene la URL del avatar del usuario actual.
  String? getAvatarUrl() {
    _loadFromBackendIfNeeded();
    return _profile?.avatarPath;
  }

  /// Obtiene el código ISO del idioma nativo del usuario.
  String getNativeLanguageCode() {
    _loadFromBackendIfNeeded();
    return _profile?.nativeLanguage ?? 'es';
  }
}

