/// Servicio para obtener estadísticas del usuario.
///
/// BACKEND: Este servicio debe ser sustituido por una implementación
/// que obtenga las estadísticas desde el backend.
///
/// TODO(BE): Exponer en /api/stats o /api/profile/stats los siguientes campos:
///   - exchangesThisMonth: int
///   - exchangesLastMonth: int
///   - hoursThisWeek: double
///   - hoursLastWeek: double
///
/// TODO(FE): Reemplazar este mock por implementación conectada a:
///   - UsersRepository o endpoint de estadísticas
///   - Cachear datos en memoria/almacenamiento local
class StatsService {
  // Singleton pattern para acceso global
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  /// Obtiene el número de intercambios del mes actual.
  ///
  /// BACKEND: Debe provenir del endpoint /api/stats o /api/profile/stats.
  int getExchangesThisMonth() {
    // TODO(BE): Obtener desde backend
    // TODO(FE): Sustituir por llamada al repositorio real
    return 12; // Mock: 12 intercambios este mes
  }

  /// Obtiene el número de intercambios del mes anterior.
  ///
  /// BACKEND: Debe provenir del endpoint /api/stats o /api/profile/stats.
  int getExchangesLastMonth() {
    // TODO(BE): Obtener desde backend
    // TODO(FE): Sustituir por llamada al repositorio real
    return 9; // Mock: 9 intercambios el mes pasado
  }

  /// Obtiene las horas totales de esta semana.
  ///
  /// BACKEND: Debe provenir del endpoint /api/stats o /api/profile/stats.
  double getHoursThisWeek() {
    // TODO(BE): Obtener desde backend
    // TODO(FE): Sustituir por llamada al repositorio real
    return 5.0; // Mock: 5 horas esta semana
  }

  /// Obtiene las horas totales de la semana anterior.
  ///
  /// BACKEND: Debe provenir del endpoint /api/stats o /api/profile/stats.
  double getHoursLastWeek() {
    // TODO(BE): Obtener desde backend
    // TODO(FE): Sustituir por llamada al repositorio real
    return 0.0; // Mock: 0 horas la semana pasada (primera semana)
  }
}
