/// Categorías de temas generados por IA
enum TopicCategory {
  conversation,
  debate,
  roleplay;

  String get displayName {
    switch (this) {
      case TopicCategory.conversation:
        return 'Conversation';
      case TopicCategory.debate:
        return 'Debate';
      case TopicCategory.roleplay:
        return 'Roleplay';
    }
  }

  String get apiValue {
    return name.toUpperCase();
  }

  static TopicCategory fromString(String value) {
    return TopicCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TopicCategory.conversation,
    );
  }
}

/// Tema generado por IA para practicar conversaciones
class GeneratedTopic {
  final String? id;
  final TopicCategory category;
  final String level;
  final String mainText;
  final String? positionA;
  final String? positionB;
  final List<String> suggestedVocabulary;
  final String language;
  final DateTime generatedAt;
  final bool isFavorite;

  const GeneratedTopic({
    this.id,
    required this.category,
    required this.level,
    required this.mainText,
    this.positionA,
    this.positionB,
    required this.suggestedVocabulary,
    required this.language,
    required this.generatedAt,
    this.isFavorite = false,
  });

  factory GeneratedTopic.fromJson(Map<String, dynamic> json) {
    return GeneratedTopic(
      id: json['id']?.toString(),
      category: TopicCategory.fromString(json['category'] as String? ?? 'conversation'),
      level: json['level'] as String? ?? 'intermediate',
      mainText: json['mainText'] as String? ?? '',
      positionA: json['positionA'] as String?,
      positionB: json['positionB'] as String?,
      suggestedVocabulary: (json['suggestedVocabulary'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      language: json['language'] as String? ?? 'es',
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'] as String)
          : DateTime.now(),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category': category.apiValue,
      'level': level,
      'mainText': mainText,
      if (positionA != null) 'positionA': positionA,
      if (positionB != null) 'positionB': positionB,
      'suggestedVocabulary': suggestedVocabulary,
      'language': language,
      'generatedAt': generatedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  GeneratedTopic copyWith({
    String? id,
    TopicCategory? category,
    String? level,
    String? mainText,
    String? positionA,
    String? positionB,
    List<String>? suggestedVocabulary,
    String? language,
    DateTime? generatedAt,
    bool? isFavorite,
  }) {
    return GeneratedTopic(
      id: id ?? this.id,
      category: category ?? this.category,
      level: level ?? this.level,
      mainText: mainText ?? this.mainText,
      positionA: positionA ?? this.positionA,
      positionB: positionB ?? this.positionB,
      suggestedVocabulary: suggestedVocabulary ?? this.suggestedVocabulary,
      language: language ?? this.language,
      generatedAt: generatedAt ?? this.generatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
