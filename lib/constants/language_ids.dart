/// Mapeo de códigos de idioma a IDs del backend
///
/// Este archivo centraliza el mapeo entre los códigos de idioma usados
/// en la aplicación (ES, EN, FR, etc.) y los IDs correspondientes en la base de datos del backend.
class LanguageIds {
  static const Map<String, int> codeToId = {
    'ES': 1, // Español
    'EN': 2, // Inglés
    'FR': 3, // Francés
    'DE': 4, // Alemán
    'IT': 5, // Italiano
    'PT': 6, // Portugués
    'ZH': 7, // Chino
    'JA': 8, // Japonés
    'RU': 9, // Ruso
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
  static const List<String> learningCodesSupportedByBackend = ['ES', 'EN', 'FR', 'DE', 'IT'];
}

