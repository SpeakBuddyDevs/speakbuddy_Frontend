class LanguageItem {
  final String code;
  final String name;
  final String level;
  final bool active;
  
  const LanguageItem({
    required this.code,
    required this.name,
    required this.level,
    this.active = false,
  });
}

