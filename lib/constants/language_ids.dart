/// Mapeo de códigos de idioma a IDs del backend
///
/// Este archivo centraliza el mapeo entre los códigos de idioma usados
/// en la aplicación (ES, EN, FR, etc.) y los IDs correspondientes en la base de datos del backend.
class LanguageIds {
  static const Map<String, int> codeToId = {
    'es': 1, // Español
    'en': 2, // Inglés
    'fr': 3, // Francés
    'de': 4, // Alemán
    'it': 5, // Italiano
    'pt': 6, // Portugués
    'zh': 7, // Chino
    'ja': 8, // Japonés
  };

  /// Obtiene el ID del backend a partir del código de idioma.
  /// Retorna null si el código no existe.
  static int? getId(String code) {
    return codeToId[code];
  }

  /// Obtiene el código de idioma a partir del ID del backend.
  /// Retorna null si el ID no existe.
  static String? getCode(int id) {
    for (final entry in codeToId.entries) {
      if (entry.value == id) {
        return entry.key;
      }
    }
    return null;
  }

  /// Códigos que el backend tiene en DataInitializer (solo ES, EN, FR, DE, IT).
  /// Usar al añadir idiomas de aprendizaje para evitar "Language not found".
  static const List<String> learningCodesSupportedByBackend = [
    'es',
    'en',
    'fr',
    'de',
    'it',
  ];
}
