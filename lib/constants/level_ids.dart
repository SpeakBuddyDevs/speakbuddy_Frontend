/// Mapeo de niveles de idioma a IDs del backend
///
/// Los IDs corresponden a la tabla `language_levels` en la base de datos:
/// 1 = A1 - Beginner
/// 2 = A2 - Elementary
/// 3 = B1 - Intermediate
/// 4 = B2 - Upper Intermediate
/// 5 = C1 - Advanced
/// 6 = C2 - Proficient
class LevelIds {
  LevelIds._();

  /// Mapeo de nombres de nivel (frontend) a IDs del backend
  static const Map<String, int> nameToId = {
    'A1 - Principiante': 1,    // A1
    'A2 - Elemental': 2,       // A2
    'B1 - Intermedio': 3,      // B1
    'B2 - Intermedio Alto': 4, // B2
    'C1 - Avanzado': 5,        // C1
    'C2 - Proficiency': 6,      // C2
  };

  /// Mapeo inverso: ID a nombre de nivel
  static const Map<int, String> idToName = {
    1: 'A1 - Principiante',
    2: 'A2 - Elemental',
    3: 'B1 - Intermedio',
    4: 'B2 - Intermedio Alto',
    5: 'C1 - Avanzado',
    6: 'C2 - Proficiency',
  };

  /// Obtiene el ID del nivel por nombre, o null si no existe
  static int? getId(String levelName) => nameToId[levelName];

  /// Obtiene el nombre del nivel por ID, o null si no existe
  static String? getName(int levelId) => idToName[levelId];

  /// Lista de niveles disponibles (para mostrar en selector)
  static List<String> get availableLevels => nameToId.keys.toList();
}
