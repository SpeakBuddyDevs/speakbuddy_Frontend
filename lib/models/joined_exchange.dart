/// Modelo para intercambios a los que el usuario está unido.
/// Mapea la respuesta de GET /api/exchanges/joined y GET /api/exchanges/{id}
class JoinedExchange {
  final String id;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status; // SCHEDULED, ENDED_PENDING_CONFIRMATION, COMPLETED, CANCELLED
  final String type;
  final String? title;
  final DateTime createdAt;
  final List<JoinedExchangeParticipant> participants;
  final bool canConfirm;
  final bool allConfirmed;
  final DateTime? lastMessageAt;
  final String? nativeLanguage;
  final String? targetLanguage;
  final List<String> platforms;
  final int? maxParticipants;
  final List<String> topics;

  const JoinedExchange({
    required this.id,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    required this.type,
    this.title,
    required this.createdAt,
    required this.participants,
    required this.canConfirm,
    required this.allConfirmed,
    this.lastMessageAt,
    this.nativeLanguage,
    this.targetLanguage,
    this.platforms = const [],
    this.maxParticipants,
    this.topics = const [],
  });

  factory JoinedExchange.fromJson(Map<String, dynamic> json) {
    final participants = (json['participants'] as List<dynamic>?)
            ?.map((e) => JoinedExchangeParticipant.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final scheduledAt = json['scheduledAt'] as String?;
    final createdAt = json['createdAt'] as String?;
    final lastMessageAtRaw = json['lastMessageAt'];
    DateTime? lastMessageAt;
    if (lastMessageAtRaw != null) {
      if (lastMessageAtRaw is String) {
        lastMessageAt = DateTime.tryParse(lastMessageAtRaw);
      } else if (lastMessageAtRaw is List && lastMessageAtRaw.length >= 6) {
        final y = (lastMessageAtRaw[0] as num?)?.toInt() ?? 0;
        final m = (lastMessageAtRaw[1] as num?)?.toInt() ?? 1;
        final d = (lastMessageAtRaw[2] as num?)?.toInt() ?? 1;
        final h = (lastMessageAtRaw[3] as num?)?.toInt() ?? 0;
        final min = (lastMessageAtRaw[4] as num?)?.toInt() ?? 0;
        final sec = (lastMessageAtRaw[5] as num?)?.toInt() ?? 0;
        lastMessageAt = DateTime(y, m, d, h, min, sec);
      }
    }

    return JoinedExchange(
      id: json['id']?.toString() ?? '',
      scheduledAt: scheduledAt != null ? DateTime.parse(scheduledAt) : DateTime.now(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'SCHEDULED',
      type: json['type'] as String? ?? 'group',
      title: json['title'] as String?,
      createdAt: createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
      participants: participants,
      canConfirm: json['canConfirm'] == true,
      allConfirmed: json['allConfirmed'] == true,
      lastMessageAt: lastMessageAt,
      nativeLanguage: json['nativeLanguage'] as String?,
      targetLanguage: json['targetLanguage'] as String?,
      platforms: (json['platforms'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}

class JoinedExchangeParticipant {
  final int userId;
  final String username;
  final bool confirmed;
  final String role;
  final String? avatarUrl;
  final double? rating;
  final String? country;
  final bool isPro;

  const JoinedExchangeParticipant({
    required this.userId,
    required this.username,
    required this.confirmed,
    required this.role,
    this.avatarUrl,
    this.rating,
    this.country,
    this.isPro = false,
  });

  factory JoinedExchangeParticipant.fromJson(Map<String, dynamic> json) {
    return JoinedExchangeParticipant(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      confirmed: json['confirmed'] == true,
      role: json['role'] as String? ?? 'participant',
      avatarUrl: json['avatarUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      country: json['country'] as String?,
      isPro: json['isPro'] == true,
    );
  }
}
