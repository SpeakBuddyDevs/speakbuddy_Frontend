import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

/// Guarda la última fecha de mensaje "vista" por el usuario en cada chat de intercambio.
/// Se usa para mostrar el indicador "mensajes nuevos" en la tarjeta.
/// La clave incluye el id del usuario actual para que al cambiar de sesión cada usuario
/// tenga su propio estado "último visto".
class ExchangeChatReadService {
  static const String _prefix = 'chat_last_seen_';

  Future<String> _key(String exchangeId) async {
    final userId = await AuthService().getCurrentUserId();
    return '$_prefix${userId ?? 'anon'}_$exchangeId';
  }

  Future<void> setLastSeenAt(String exchangeId, DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    final k = await _key(exchangeId);
    await prefs.setString(k, dateTime.toIso8601String());
  }

  Future<DateTime?> getLastSeenAt(String exchangeId) async {
    final prefs = await SharedPreferences.getInstance();
    final k = await _key(exchangeId);
    final s = prefs.getString(k);
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  /// Devuelve true si hay mensajes nuevos (lastMessageAt > lastSeenAt o nunca visto con mensajes).
  Future<bool> hasNewMessages(String exchangeId, DateTime? lastMessageAt) async {
    if (lastMessageAt == null) return false;
    final lastSeen = await getLastSeenAt(exchangeId);
    if (lastSeen == null) return true; // Nunca abrió el chat → hay "nuevos"
    return lastMessageAt.isAfter(lastSeen);
  }
}
