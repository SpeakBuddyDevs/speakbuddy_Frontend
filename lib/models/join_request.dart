/// Modelo para solicitudes de unión a intercambios públicos.
/// Mapea la respuesta de GET /api/exchanges/{id}/join-requests
class JoinRequest {
  final int id;
  final int userId;
  final String username;
  final DateTime createdAt;
  final List<String>? unmetRequirements;

  const JoinRequest({
    required this.id,
    required this.userId,
    required this.username,
    required this.createdAt,
    this.unmetRequirements,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    DateTime createdAt = DateTime.now();
    if (createdAtRaw != null) {
      if (createdAtRaw is String) {
        createdAt = DateTime.tryParse(createdAtRaw) ?? createdAt;
      } else if (createdAtRaw is List && createdAtRaw.length >= 6) {
        final y = (createdAtRaw[0] as num?)?.toInt() ?? 0;
        final m = (createdAtRaw[1] as num?)?.toInt() ?? 1;
        final d = (createdAtRaw[2] as num?)?.toInt() ?? 1;
        final h = (createdAtRaw[3] as num?)?.toInt() ?? 0;
        final min = (createdAtRaw[4] as num?)?.toInt() ?? 0;
        final sec = (createdAtRaw[5] as num?)?.toInt() ?? 0;
        createdAt = DateTime(y, m, d, h, min, sec);
      }
    }

    final unmetRaw = json['unmetRequirements'];
    List<String>? unmetRequirements;
    if (unmetRaw is List) {
      final list = unmetRaw
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      unmetRequirements = list.isEmpty ? null : list;
    }

    return JoinRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      username: (json['username'] as String?) ?? '',
      createdAt: createdAt,
      unmetRequirements: unmetRequirements,
    );
  }
}
