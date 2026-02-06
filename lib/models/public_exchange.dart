// Mapea cada elemento del array en GET /api/exchanges/public (content de Page)
// Response: { id, title, description, creatorId, creatorName, creatorAvatarUrl?,
//   creatorIsPro, requiredLevel, minLevel, scheduledAt, durationMinutes, currentParticipants,
//   maxParticipants, nativeLanguage, targetLanguage, topics[]?, isEligible,
//   unmetRequirements[]?, isPublic, shareLink? }
//
// Concepto: Intercambio mutuo de idiomas. El creador ofrece su idioma nativo (nativeLanguage)
// a cambio de practicar otro idioma (targetLanguage). La conversación se divide a partes
// iguales entre ambos idiomas.

/// Modelo para intercambios públicos (sesiones grupales de intercambio mutuo de idiomas)
class PublicExchange {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String creatorName;
  final String? creatorAvatarUrl;
  final bool creatorIsPro; // Si el creador tiene suscripción PRO
  final String requiredLevel; // "Principiante", "Intermedio", "Avanzado"
  final int minLevel; // Nivel numérico mínimo (1-10) para el idioma objetivo
  final DateTime date;
  final int durationMinutes;
  final int currentParticipants;
  final int maxParticipants;
  final String nativeLanguage; // Idioma nativo que el creador ofrece
  final String targetLanguage; // Idioma que el creador quiere practicar
  final List<String>? topics; // Temas/categorías opcionales
  final bool isEligible; // Si el usuario actual cumple requisitos
  final List<String>? unmetRequirements; // Requisitos no cumplidos si !isEligible
  final bool isJoined; // Si el usuario actual ya es participante
  final bool isPublic; // true = público, false = privado
  final String? shareLink; // Enlace compartible para intercambios privados

  const PublicExchange({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.creatorName,
    this.creatorAvatarUrl,
    this.creatorIsPro = false,
    required this.requiredLevel,
    required this.minLevel,
    required this.date,
    required this.durationMinutes,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.nativeLanguage,
    required this.targetLanguage,
    this.topics,
    required this.isEligible,
    this.unmetRequirements,
    this.isJoined = false,
    this.isPublic = true, // Por defecto público
    this.shareLink,
  });

  /// Parsea la respuesta del backend (elemento de content en GET /api/exchanges/public)
  factory PublicExchange.fromJson(Map<String, dynamic> json) {
    final scheduledAt = json['scheduledAt'] as String?;
    DateTime date;
    if (scheduledAt != null && scheduledAt.isNotEmpty) {
      date = DateTime.parse(scheduledAt);
    } else {
      date = DateTime.now();
    }

    final topicsRaw = json['topics'];
    List<String>? topics;
    if (topicsRaw is List) {
      topics = topicsRaw
          .where((e) => e != null)
          .map((e) => e.toString())
          .toList();
      if (topics.isEmpty) topics = null;
    }

    final unmetRaw = json['unmetRequirements'];
    List<String>? unmetRequirements;
    if (unmetRaw is List) {
      unmetRequirements = unmetRaw
          .where((e) => e != null)
          .map((e) => e.toString())
          .toList();
      if (unmetRequirements.isEmpty) unmetRequirements = null;
    }

    return PublicExchange(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Intercambio').toString(),
      description: (json['description'] ?? '').toString(),
      creatorId: (json['creatorId'] ?? '').toString(),
      creatorName: (json['creatorName'] ?? '').toString(),
      creatorAvatarUrl: json['creatorAvatarUrl']?.toString(),
      creatorIsPro: json['creatorIsPro'] == true,
      requiredLevel: (json['requiredLevel'] ?? 'Principiante').toString(),
      minLevel: (json['minLevel'] is int)
          ? json['minLevel'] as int
          : int.tryParse((json['minLevel'] ?? '1').toString()) ?? 1,
      date: date,
      durationMinutes: (json['durationMinutes'] is int)
          ? json['durationMinutes'] as int
          : int.tryParse((json['durationMinutes'] ?? '0').toString()) ?? 0,
      currentParticipants: (json['currentParticipants'] is int)
          ? json['currentParticipants'] as int
          : int.tryParse((json['currentParticipants'] ?? '0').toString()) ?? 0,
      maxParticipants: (json['maxParticipants'] is int)
          ? json['maxParticipants'] as int
          : int.tryParse((json['maxParticipants'] ?? '1').toString()) ?? 1,
      nativeLanguage: (json['nativeLanguage'] ?? '').toString(),
      targetLanguage: (json['targetLanguage'] ?? '').toString(),
      topics: topics,
      isEligible: json['isEligible'] == true,
      unmetRequirements: unmetRequirements,
      isJoined: json['isJoined'] == true,
      isPublic: json['isPublic'] != false,
      shareLink: json['shareLink']?.toString(),
    );
  }
}
