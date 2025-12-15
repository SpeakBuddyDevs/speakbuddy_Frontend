class AppLanguages {
  static const Map<String, String> codeToName = {
    'ES': 'Español',
    'EN': 'Inglés',
    'FR': 'Francés',
    'DE': 'Alemán',
    'IT': 'Italiano',
    'PT': 'Portugués',
    'ZH': 'Chino',
    'JA': 'Japonés',
    'RU': 'Ruso',
  };

  /// Obtiene el nombre del idioma a partir de su código.
  /// Si el código no existe, retorna el código mismo.
  static String getName(String code) {
    return codeToName[code] ?? code;
  }

  /// Retorna la lista de códigos de idiomas disponibles.
  static List<String> get availableCodes => codeToName.keys.toList();
}

