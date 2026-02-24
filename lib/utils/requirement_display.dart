/// Translates requirement strings from backend (possibly in Spanish) to English for UI.
String translateRequirement(String text) {
  String result = text;
  result = result.replaceAll('Idioma nativo:', 'Native language:');
  result = result.replaceAll('Nivel de Español:', 'Spanish level:');
  result = result.replaceAll('Nivel de Inglés:', 'English level:');
  result = result.replaceAll('Nivel de Francés:', 'French level:');
  result = result.replaceAll('Nivel de Alemán:', 'German level:');
  result = result.replaceAll('Nivel de Italiano:', 'Italian level:');
  result = result.replaceAll('Nivel de Portugués:', 'Portuguese level:');
  result = result.replaceAll('Nivel de Chino:', 'Chinese level:');
  result = result.replaceAll('Nivel de Japonés:', 'Japanese level:');
  return result;
}
