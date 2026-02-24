import 'package:flutter/foundation.dart';

import '../models/joined_exchange.dart';
import '../repositories/api_exchange_repository.dart';
import '../repositories/api_public_exchanges_repository.dart';
import '../repositories/api_user_exchanges_repository.dart';
import '../repositories/user_exchanges_repository.dart';
import '../services/current_user_service.dart';
import '../services/exchange_chat_read_service.dart';
import '../services/stats_service.dart';
import '../services/unread_notifications_service.dart';

/// ViewModel para la pantalla de Home.
///
/// Encapsula:
/// - Carga y refresco de intercambios unidos.
/// - Cálculo de banderas de nuevos mensajes por intercambio.
/// - Carga de estadísticas de uso.
/// - Acciones de dominio sobre intercambios (confirmar, abandonar).
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    UserExchangesRepository? userExchangesRepository,
    ApiExchangeRepository? exchangeRepository,
    ApiPublicExchangesRepository? publicExchangesRepository,
    StatsService? statsService,
    ExchangeChatReadService? chatReadService,
    UnreadNotificationsService? unreadNotificationsService,
    CurrentUserService? currentUserService,
  })  : _userExchangesRepository =
            userExchangesRepository ?? ApiUserExchangesRepository(),
        _exchangeRepository = exchangeRepository ?? ApiExchangeRepository(),
        _publicExchangesRepository =
            publicExchangesRepository ?? ApiPublicExchangesRepository(),
        _statsService = statsService ?? StatsService(),
        _chatReadService = chatReadService ?? ExchangeChatReadService(),
        _unreadNotificationsService =
            unreadNotificationsService ?? UnreadNotificationsService(),
        _currentUserService = currentUserService ?? CurrentUserService();

  final UserExchangesRepository _userExchangesRepository;
  final ApiExchangeRepository _exchangeRepository;
  final ApiPublicExchangesRepository _publicExchangesRepository;
  final StatsService _statsService;
  final ExchangeChatReadService _chatReadService;
  final UnreadNotificationsService _unreadNotificationsService;
  final CurrentUserService _currentUserService;

  List<JoinedExchange>? _joinedExchanges;
  Map<String, bool> _hasNewMessages = {};
  bool _isLoadingExchanges = true;
  int _exchangesThisMonth = 0;
  int _exchangesLastMonth = 0;
  double _hoursThisWeek = 0.0;
  double _hoursLastWeek = 0.0;

  List<JoinedExchange>? get joinedExchanges => _joinedExchanges;

  Map<String, bool> get hasNewMessages => _hasNewMessages;

  bool get isLoadingExchanges => _isLoadingExchanges;

  int get exchangesThisMonth => _exchangesThisMonth;

  int get exchangesLastMonth => _exchangesLastMonth;

  double get hoursThisWeek => _hoursThisWeek;

  double get hoursLastWeek => _hoursLastWeek;

  UnreadNotificationsService get unreadNotificationsService =>
      _unreadNotificationsService;

  int get pendingConfirmCount =>
      _joinedExchanges?.where((e) => e.canConfirm).length ?? 0;

  List<JoinedExchange> get pendingExchanges =>
      _joinedExchanges
          ?.where((e) => e.status != 'COMPLETED' && e.status != 'CANCELLED')
          .toList() ??
      [];

  List<JoinedExchange> get completedExchanges =>
      _joinedExchanges
          ?.where((e) => e.status == 'COMPLETED')
          .toList() ??
      [];

  /// Recarga las estadísticas de uso del usuario.
  ///
  /// Usa la caché de `StatsService` por defecto y permite forzar refresco
  /// desde el backend pasando `force: true` después de acciones que
  /// alteran las estadísticas (por ejemplo, confirmar un intercambio).
  Future<void> reloadStats({bool force = false}) async {
    try {
      final stats = await _statsService.fetchStats(forceRefresh: force);
      _exchangesThisMonth = stats.exchangesThisMonth;
      _exchangesLastMonth = stats.exchangesLastMonth;
      _hoursThisWeek = stats.hoursThisWeek;
      _hoursLastWeek = stats.hoursLastWeek;
      notifyListeners();
    } catch (_) {
      // En caso de error, mantener los valores actuales.
    }
  }

  /// Carga inicial de datos para la Home:
  /// - Datos del usuario actual (para header).
  /// - Intercambios unidos + nuevos mensajes.
  /// - Estadísticas.
  /// - Notificaciones no leídas.
  Future<void> loadInitialData() async {
    await _currentUserService.preload();

    await Future.wait([
      loadExchanges(),
      reloadStats(),
      _unreadNotificationsService.refresh(),
    ]);
  }

  /// Carga/recarga los intercambios unidos del usuario.
  Future<void> loadExchanges() async {
    _isLoadingExchanges = true;
    notifyListeners();

    try {
      final exchanges = await _userExchangesRepository.getJoinedExchanges();
      _joinedExchanges = exchanges;
      _isLoadingExchanges = false;
      notifyListeners();

      await _refreshHasNewMessages();
    } catch (_) {
      _joinedExchanges = [];
      _isLoadingExchanges = false;
      notifyListeners();
    }
  }

  Future<void> _refreshHasNewMessages() async {
    final exchanges = _joinedExchanges;
    if (exchanges == null || exchanges.isEmpty) return;
    final map = <String, bool>{};
    for (final e in exchanges) {
      map[e.id] = await _chatReadService.hasNewMessages(e.id, e.lastMessageAt);
    }
    _hasNewMessages = map;
    notifyListeners();
  }

  /// Lanza la confirmación de un intercambio en el backend.
  ///
  /// La lógica de navegación y snackbars se deja en la capa de UI.
  Future<void> confirmExchange(String exchangeId) async {
    await _exchangeRepository.confirm(exchangeId);
    await _currentUserService.preload();
    await Future.wait([
      loadExchanges(),
      reloadStats(force: true),
    ]);
  }

  /// Abandona un intercambio en el backend.
  ///
  /// La UI decide cuándo pedir confirmación al usuario y mostrar mensajes.
  Future<void> leaveExchange(String exchangeId) async {
    await _publicExchangesRepository.leaveExchange(exchangeId);
    await loadExchanges();
  }
}

