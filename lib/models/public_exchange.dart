// BACKEND: Mapea cada elemento del array en GET /api/exchanges/public
// TODO(FE): Implementar factory PublicExchange.fromJson(Map<String, dynamic>)
// Response esperado: { id, title, description, creatorId, creatorName, creatorAvatarUrl?,
//   creatorIsPro, requiredLevel, minLevel, date, durationMinutes, currentParticipants,
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
    this.isPublic = true, // Por defecto público
    this.shareLink,
  });
}
