import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common/app_header.dart';
import '../services/current_user_service.dart';
import '../services/stats_service.dart';
import '../repositories/api_user_exchanges_repository.dart';
import '../repositories/api_exchange_repository.dart';
import '../repositories/api_public_exchanges_repository.dart';
import '../repositories/user_exchanges_repository.dart';
import '../models/joined_exchange.dart';
import '../constants/routes.dart';
import '../constants/dimensions.dart';
import '../navigation/exchange_chat_args.dart';
import '../services/exchange_chat_read_service.dart';
import '../widgets/exchange/joined_exchange_card.dart';

/// Pantalla principal de la aplicación
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final UserExchangesRepository _repository = ApiUserExchangesRepository();
  final ApiExchangeRepository _exchangeRepo = ApiExchangeRepository();
  final ApiPublicExchangesRepository _leaveRepo = ApiPublicExchangesRepository();
  final StatsService _statsService = StatsService();
  final ExchangeChatReadService _chatReadService = ExchangeChatReadService();

  List<JoinedExchange>? _joinedExchanges;
  Map<String, bool> _hasNewMessages = {};
  bool _isLoadingExchanges = true;
  int _exchangesThisMonth = 0;
  int _exchangesLastMonth = 0;
  double _hoursThisWeek = 0.0;
  double _hoursLastWeek = 0.0;
  final GlobalKey _exchangesSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadExchanges();
    }
  }

  Future<void> _loadData() async {
    // Precargar datos del usuario actual para que el header
    // pueda mostrar nombre y estado PRO reales.
    await CurrentUserService().preload();

    await Future.wait([
      _loadExchanges(),
      _loadStats(),
    ]);
  }

  Future<void> _loadExchanges() async {
    setState(() {
      _isLoadingExchanges = true;
    });

    try {
      final exchanges = await _repository.getJoinedExchanges();
      if (!mounted) return;
      setState(() {
        _joinedExchanges = exchanges;
        _isLoadingExchanges = false;
      });
      _refreshHasNewMessages();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _joinedExchanges = [];
        _isLoadingExchanges = false;
      });
    }
  }

  Future<void> _refreshHasNewMessages() async {
    final exchanges = _joinedExchanges;
    if (exchanges == null || exchanges.isEmpty) return;
    final map = <String, bool>{};
    for (final e in exchanges) {
      map[e.id] = await _chatReadService.hasNewMessages(e.id, e.lastMessageAt);
    }
    if (!mounted) return;
    setState(() => _hasNewMessages = map);
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _statsService.fetchStats();
      if (!mounted) return;
      setState(() {
        _exchangesThisMonth = stats.exchangesThisMonth;
        _exchangesLastMonth = stats.exchangesLastMonth;
        _hoursThisWeek = stats.hoursThisWeek;
        _hoursLastWeek = stats.hoursLastWeek;
      });
    } catch (e) {
      if (!mounted) return;
      // En caso de error, mantenemos los valores actuales (por defecto 0)
      // y no rompemos la Home.
    }
  }

  void _onGoToPublicExchanges() {
    Navigator.pushNamed(context, AppRoutes.publicExchanges);
  }

  int get _pendingConfirmCount =>
      _joinedExchanges?.where((e) => e.canConfirm).length ?? 0;

  List<JoinedExchange> get _pendingExchanges =>
      _joinedExchanges
          ?.where((e) =>
              e.status != 'COMPLETED' && e.status != 'CANCELLED')
          .toList() ??
      [];

  List<JoinedExchange> get _completedExchanges =>
      _joinedExchanges
          ?.where((e) => e.status == 'COMPLETED')
          .toList() ??
      [];

  void _onGoToHistory() {
    Navigator.pushNamed(
      context,
      AppRoutes.exchangeHistory,
      arguments: _completedExchanges,
    );
  }

  void _onScrollToExchanges() {
    final context = _exchangesSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        alignment: 0.2,
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _onConfirmExchange(JoinedExchange exchange) async {
    try {
      await _exchangeRepo.confirm(exchange.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intercambio confirmado')),
      );
      _loadExchanges();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _onLeaveExchange(JoinedExchange exchange) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('Abandonar intercambio'),
        content: const Text(
          '¿Estás seguro de que quieres abandonar este intercambio?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Abandonar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _leaveRepo.leaveExchange(exchange.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Has abandonado "${exchange.title ?? 'Intercambio'}"'),
        ),
      );
      _loadExchanges();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  void _onOpenExchangeChat(JoinedExchange exchange) {
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: ExchangeChatArgs(exchangeId: exchange.id),
    ).then((_) {
      if (!mounted) return;
      _loadExchanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userService = CurrentUserService();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppHeader(
        userName: userService.getDisplayName(),
        level: userService.getLevel(),
        levelProgress: userService.getProgressToNextLevel(),
        isPro: userService.isPro(),
        onNotificationsTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notificaciones próximamente')),
          );
        },
        onProTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pro próximamente')),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.accent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppDimensions.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner: intercambios pendientes de confirmar
              if (_pendingConfirmCount > 0) ...[
                _PendingConfirmBanner(
                  count: _pendingConfirmCount,
                  onTap: _onScrollToExchanges,
                ),
                const SizedBox(height: AppDimensions.spacingL),
              ],
              // Tarjetas de estadísticas
              _StatsRow(
                exchangesThisMonth: _exchangesThisMonth,
                exchangesLastMonth: _exchangesLastMonth,
                hoursThisWeek: _hoursThisWeek,
                hoursLastWeek: _hoursLastWeek,
              ),
              const SizedBox(height: AppDimensions.spacingL),
              // Sección de intercambios pendientes
              _PendingExchangesSection(
                key: _exchangesSectionKey,
                pendingExchanges: _pendingExchanges,
                isLoading: _isLoadingExchanges,
                onGoToPublicExchanges: _onGoToPublicExchanges,
                onGoToHistory: _onGoToHistory,
                onRefresh: _loadExchanges,
                onConfirm: _onConfirmExchange,
                onLeave: _onLeaveExchange,
                onOpenChat: _onOpenExchangeChat,
                hasNewMessages: _hasNewMessages,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila de tarjetas de estadísticas
class _StatsRow extends StatelessWidget {
  final int exchangesThisMonth;
  final int exchangesLastMonth;
  final double hoursThisWeek;
  final double hoursLastWeek;

  const _StatsRow({
    required this.exchangesThisMonth,
    required this.exchangesLastMonth,
    required this.hoursThisWeek,
    required this.hoursLastWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatsCard(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Intercambios',
            value: '$exchangesThisMonth',
            comparison: _calculateComparison(
              exchangesThisMonth.toDouble(),
              exchangesLastMonth.toDouble(),
              isMonthly: true,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        Expanded(
          child: _StatsCard(
            icon: Icons.access_time_rounded,
            title: 'Horas',
            value: '${hoursThisWeek.toStringAsFixed(0)}h',
            comparison: _calculateComparison(
              hoursThisWeek,
              hoursLastWeek,
              isMonthly: false,
            ),
          ),
        ),
      ],
    );
  }

  _ComparisonData _calculateComparison(
    double current,
    double previous, {
    required bool isMonthly,
  }) {
    final diff = current - previous;
    final isPositive = diff >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    String text;
    if (isMonthly) {
      final diffInt = diff.abs().round();
      text = isPositive ? '+$diffInt mes' : '-$diffInt mes';
    } else {
      final diffStr = diff.abs().toStringAsFixed(0);
      text = isPositive ? '+${diffStr}h sem.' : '-${diffStr}h sem.';
    }

    return _ComparisonData(text: text, color: color, icon: icon);
  }
}

/// Datos de comparación para las tarjetas de estadísticas
class _ComparisonData {
  final String text;
  final Color color;
  final IconData icon;

  const _ComparisonData({
    required this.text,
    required this.color,
    required this.icon,
  });
}

/// Tarjeta de estadística individual
class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final _ComparisonData comparison;

  const _StatsCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppTheme.border),
      ),
      padding: AppDimensions.paddingCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.subtle, size: AppDimensions.iconSizeM),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.text,
              fontSize: AppDimensions.fontSizeXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Row(
            children: [
              Icon(comparison.icon, color: comparison.color, size: AppDimensions.iconSizeS),
              const SizedBox(width: AppDimensions.spacingXS),
              Text(
                comparison.text,
                style: TextStyle(
                  color: comparison.color,
                  fontSize: AppDimensions.fontSizeXS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Banner de notificación in-app: intercambios pendientes de confirmar
class _PendingConfirmBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _PendingConfirmBanner({
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = count == 1
        ? 'Tienes 1 intercambio pendiente de confirmar'
        : 'Tienes $count intercambios pendientes de confirmar';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingL,
            vertical: AppDimensions.spacingMD,
          ),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: AppTheme.accent,
                size: AppDimensions.iconSizeL,
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: AppDimensions.fontSizeS,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: onTap,
                child: Text(
                  'Ver',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sección de intercambios pendientes
class _PendingExchangesSection extends StatelessWidget {
  final List<JoinedExchange> pendingExchanges;
  final bool isLoading;
  final VoidCallback onGoToPublicExchanges;
  final VoidCallback onGoToHistory;
  final VoidCallback onRefresh;
  final Future<void> Function(JoinedExchange) onConfirm;
  final Future<void> Function(JoinedExchange) onLeave;
  final void Function(JoinedExchange) onOpenChat;
  final Map<String, bool> hasNewMessages;

  const _PendingExchangesSection({
    super.key,
    required this.pendingExchanges,
    required this.isLoading,
    required this.onGoToPublicExchanges,
    required this.onGoToHistory,
    required this.onRefresh,
    required this.onConfirm,
    required this.onLeave,
    required this.onOpenChat,
    required this.hasNewMessages,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con icono de calendario (navega al historial)
        Row(
          children: [
            Text(
              'Intercambios Pendientes',
              style: TextStyle(
                color: AppTheme.text,
                fontSize: AppDimensions.fontSizeL,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onGoToHistory,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingXS),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: AppTheme.subtle,
                  size: AppDimensions.iconSizeM,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMD),
        // Contenido
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacingXL),
              child: CircularProgressIndicator(),
            ),
          )
        else if (pendingExchanges.isEmpty)
          _EmptyExchangesButton(onPressed: onGoToPublicExchanges)
        else
          _ExchangesCarousel(
            exchanges: pendingExchanges,
            onConfirm: onConfirm,
            onLeave: onLeave,
            onOpenChat: onOpenChat,
            hasNewMessages: hasNewMessages,
          ),
      ],
    );
  }
}

/// Botón cuando no hay intercambios
class _EmptyExchangesButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EmptyExchangesButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.search_rounded),
        label: const Text('Ir a Intercambios Públicos'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingL),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
      ),
    );
  }
}

/// Carrusel de intercambios pendientes
class _ExchangesCarousel extends StatefulWidget {
  final List<JoinedExchange> exchanges;
  final Future<void> Function(JoinedExchange) onConfirm;
  final Future<void> Function(JoinedExchange) onLeave;
  final void Function(JoinedExchange) onOpenChat;
  final Map<String, bool> hasNewMessages;

  const _ExchangesCarousel({
    required this.exchanges,
    required this.onConfirm,
    required this.onLeave,
    required this.onOpenChat,
    required this.hasNewMessages,
  });

  @override
  State<_ExchangesCarousel> createState() => _ExchangesCarouselState();
}

class _ExchangesCarouselState extends State<_ExchangesCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exchanges.length == 1) {
      final e = widget.exchanges[0];
      return JoinedExchangeCard(
        exchange: e,
        onConfirm: widget.onConfirm,
        onLeave: () => widget.onLeave(e),
        onOpenChat: () => widget.onOpenChat(e),
        hasNewMessages: widget.hasNewMessages[e.id] ?? false,
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.exchanges.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final exchange = widget.exchanges[index];
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.spacingMD),
                child: JoinedExchangeCard(
                  exchange: exchange,
                  onConfirm: widget.onConfirm,
                  onLeave: () => widget.onLeave(exchange),
                  onOpenChat: () => widget.onOpenChat(exchange),
                  hasNewMessages: widget.hasNewMessages[exchange.id] ?? false,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMD),
        _PageIndicators(
          count: widget.exchanges.length,
          currentIndex: _currentPage,
        ),
      ],
    );
  }
}

/// Indicadores de página (dots) para el carrusel
class _PageIndicators extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageIndicators({
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          width: index == currentIndex ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index == currentIndex
                ? AppTheme.accent
                : AppTheme.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
