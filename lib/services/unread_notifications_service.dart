import 'package:flutter/foundation.dart';

import '../repositories/api_notifications_repository.dart';

/// Servicio compartido para el contador de notificaciones no leídas.
/// Todas las pantallas que muestran la campana escuchan este ValueNotifier.
/// Al llamar refresh(), todas se actualizan.
class UnreadNotificationsService {
  static final UnreadNotificationsService _instance =
      UnreadNotificationsService._internal();
  factory UnreadNotificationsService() => _instance;
  UnreadNotificationsService._internal();

  final ApiNotificationsRepository _repo = ApiNotificationsRepository();

  /// Contador actual. Las pantallas usan ValueListenableBuilder para escucharlo.
  final ValueNotifier<int> count = ValueNotifier<int>(0);

  /// Carga el contador desde la API y actualiza el ValueNotifier.
  /// Todas las pantallas que escuchan se redibujarán con el nuevo valor.
  Future<void> refresh() async {
    try {
      final value = await _repo.getUnreadCount();
      count.value = value;
    } catch (_) {
      count.value = 0;
    }
  }
}
