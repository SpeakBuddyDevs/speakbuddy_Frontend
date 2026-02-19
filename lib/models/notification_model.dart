/// Modelo de notificación in-app
class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String body;
  final String? chatId;
  final int? exchangeId;
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.chatId,
    this.exchangeId,
    required this.read,
    required this.createdAt,
  });

  bool get isDirectMessage => type == 'NEW_MESSAGE';
  bool get isExchangeMessage => type == 'NEW_EXCHANGE_MESSAGE';

  static NotificationModel fromJson(Map<String, dynamic> json) {
    final timestamp = json['createdAt'];
    DateTime createdAt = DateTime.now();
    if (timestamp != null) {
      if (timestamp is String) {
        createdAt = DateTime.tryParse(timestamp) ?? createdAt;
      } else if (timestamp is List && timestamp.length >= 6) {
        final y = (timestamp[0] as num?)?.toInt();
        final m = (timestamp[1] as num?)?.toInt();
        final d = (timestamp[2] as num?)?.toInt();
        final h = (timestamp[3] as num?)?.toInt();
        final min = (timestamp[4] as num?)?.toInt();
        final sec = (timestamp[5] as num?)?.toInt();
        if (y != null && m != null && d != null && h != null && min != null && sec != null) {
          createdAt = DateTime(y, m, d, h, min, sec);
        }
      }
    }

    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: (json['type'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      chatId: json['chatId']?.toString(),
      exchangeId: (json['exchangeId'] as num?)?.toInt(),
      read: json['read'] == true,
      createdAt: createdAt,
    );
  }
}
