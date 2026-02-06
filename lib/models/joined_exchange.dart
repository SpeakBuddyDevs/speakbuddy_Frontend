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
  });

  factory JoinedExchange.fromJson(Map<String, dynamic> json) {
    final participants = (json['participants'] as List<dynamic>?)
            ?.map((e) => JoinedExchangeParticipant.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final scheduledAt = json['scheduledAt'] as String?;
    final createdAt = json['createdAt'] as String?;

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
    );
  }
}

class JoinedExchangeParticipant {
  final int userId;
  final String username;
  final bool confirmed;
  final String role;

  const JoinedExchangeParticipant({
    required this.userId,
    required this.username,
    required this.confirmed,
    required this.role,
  });

  factory JoinedExchangeParticipant.fromJson(Map<String, dynamic> json) {
    return JoinedExchangeParticipant(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      confirmed: json['confirmed'] == true,
      role: json['role'] as String? ?? 'participant',
    );
  }
}
