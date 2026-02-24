class AppLanguages {
  static const Map<String, String> codeToName = {
    'es': 'Spanish',
    'en': 'English',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'zh': 'Chinese',
    'ja': 'Japanese',
  };

  /// Mapeo nombre → código para filtros
  static const Map<String, String> nameToCode = {
    'Spanish': 'es',
    'English': 'en',
    'French': 'fr',
    'German': 'de',
    'Italian': 'it',
    'Portuguese': 'pt',
    'Chinese': 'zh',
    'Japanese': 'ja',
  };

  /// Obtiene el nombre del idioma a partir de su código.
  /// Si el código no existe, retorna el código mismo.
  static String getName(String code) {
    return codeToName[code.toLowerCase()] ?? code;
  }

  /// Retorna la lista de códigos de idiomas disponibles.
  static List<String> get availableCodes => codeToName.keys.toList();

  /// Nombres de idiomas para filtros (alineados con nameToCode)
  static List<String> get filterLanguageNames => nameToCode.keys.toList();

  /// Idiomas soportados por el backend en la búsqueda (DataInitializer: es, en, fr, de, it)
  static const List<String> searchFilterLanguageNames = [
    'Spanish',
    'English',
    'French',
    'German',
    'Italian',
  ];

  /// Obtiene el código a partir del nombre del idioma (ej. "Español" → "es").
  static String? getCodeFromName(String name) {
    if (name.isEmpty) return null;
    return nameToCode[name];
  }
}
