import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common/app_header.dart';
import '../services/current_user_service.dart';
import '../services/stats_service.dart';
import '../repositories/fake_user_exchanges_repository.dart';
import '../repositories/user_exchanges_repository.dart';
import '../models/public_exchange.dart';
import '../constants/routes.dart';
import '../constants/dimensions.dart';
import '../utils/date_formatters.dart';
import '../navigation/exchange_chat_args.dart';

/// Pantalla principal de la aplicación
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // BACKEND: Sustituir FakeUserExchangesRepository por ApiUserExchangesRepository
  final UserExchangesRepository _repository = FakeUserExchangesRepository();
  final StatsService _statsService = StatsService();

  List<PublicExchange>? _joinedExchanges;
  bool _isLoadingExchanges = true;
  int _exchangesThisMonth = 0;
  int _exchangesLastMonth = 0;
  double _hoursThisWeek = 0.0;
  double _hoursLastWeek = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _joinedExchanges = [];
        _isLoadingExchanges = false;
      });
    }
  }

  Future<void> _loadStats() async {
    setState(() {
      _exchangesThisMonth = _statsService.getExchangesThisMonth();
      _exchangesLastMonth = _statsService.getExchangesLastMonth();
      _hoursThisWeek = _statsService.getHoursThisWeek();
      _hoursLastWeek = _statsService.getHoursLastWeek();
    });
  }

  void _onGoToPublicExchanges() {
    Navigator.pushNamed(context, AppRoutes.publicExchanges);
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
                exchanges: _joinedExchanges,
                isLoading: _isLoadingExchanges,
                onGoToPublicExchanges: _onGoToPublicExchanges,
                onRefresh: _loadExchanges,
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

/// Sección de intercambios pendientes
class _PendingExchangesSection extends StatelessWidget {
  final List<PublicExchange>? exchanges;
  final bool isLoading;
  final VoidCallback onGoToPublicExchanges;
  final VoidCallback onRefresh;

  const _PendingExchangesSection({
    required this.exchanges,
    required this.isLoading,
    required this.onGoToPublicExchanges,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con icono
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
            Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.subtle,
              size: AppDimensions.iconSizeM,
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
        else if (exchanges == null || exchanges!.isEmpty)
          _EmptyExchangesButton(onPressed: onGoToPublicExchanges)
        else
          _ExchangesCarousel(exchanges: exchanges!),
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
  final List<PublicExchange> exchanges;

  const _ExchangesCarousel({required this.exchanges});

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
      return _PendingExchangeCard(exchange: widget.exchanges[0]);
    }

    return Column(
      children: [
        SizedBox(
          height: 400, // Altura fija para el PageView
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.exchanges.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.spacingMD),
                child: _PendingExchangeCard(exchange: widget.exchanges[index]),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMD),
        // Indicadores de página
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

/// Tarjeta de intercambio pendiente
class _PendingExchangeCard extends StatelessWidget {
  final PublicExchange exchange;

  const _PendingExchangeCard({required this.exchange});

  void _onOpenChat(BuildContext context, PublicExchange exchange) {
    // TODO(FE): ChatScreen debe manejar ExchangeChatArgs para chats grupales de intercambio
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: ExchangeChatArgs(
        exchangeId: exchange.id,
        prefetchedExchange: exchange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creatorCountry = FakeUserExchangesRepository.getCreatorCountry(exchange.creatorId);
    final creatorRating = FakeUserExchangesRepository.getCreatorRating(exchange.creatorId);
    final dateStr = DateFormatters.formatExchangeDate(exchange.date);
    final topic = exchange.topics?.isNotEmpty == true ? exchange.topics!.first : null;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppTheme.border),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingCard.left,
        AppDimensions.paddingCard.top,
        AppDimensions.paddingCard.right,
        AppDimensions.spacingSM, // Padding inferior reducido para acercar el botón al borde
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Avatar, nombre, badge PRO, país, rating
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.panel,
                backgroundImage: exchange.creatorAvatarUrl != null
                    ? NetworkImage(exchange.creatorAvatarUrl!)
                    : null,
                child: exchange.creatorAvatarUrl == null
                    ? Text(
                        exchange.creatorName.isNotEmpty
                            ? exchange.creatorName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exchange.creatorName,
                            style: TextStyle(
                              color: AppTheme.text,
                              fontSize: AppDimensions.fontSizeM,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (exchange.creatorIsPro) ...[
                          const SizedBox(width: AppDimensions.spacingXS),
                          _ProBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      creatorCountry,
                      style: TextStyle(
                        color: AppTheme.subtle,
                        fontSize: AppDimensions.fontSizeS,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: AppTheme.gold,
                    size: AppDimensions.iconSizeM,
                  ),
                  const SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    creatorRating.toStringAsFixed(1),
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: AppDimensions.fontSizeM,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          // Fecha y hora
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Fecha y hora',
            value: dateStr,
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Idiomas
          _InfoRow(
            icon: Icons.translate_rounded,
            label: 'Idiomas',
            value: '${exchange.nativeLanguage} → ${exchange.targetLanguage}',
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Duración
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Duración',
            value: '${exchange.durationMinutes} min',
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Participantes
          _InfoRow(
            icon: Icons.people_outline_rounded,
            label: 'Participantes',
            value: '${exchange.currentParticipants}/${exchange.maxParticipants}',
          ),
          if (topic != null) ...[
            const SizedBox(height: AppDimensions.spacingMD),
            // Tema
            _InfoRow(
              icon: Icons.topic_outlined,
              label: 'Tema',
              value: topic,
            ),
          ],
          const SizedBox(height: AppDimensions.spacingMD),
          // Botón de chat
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _onOpenChat(context, exchange),
              icon: const Icon(Icons.chat_rounded),
              label: const Text('Abrir chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge PRO
class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          color: AppTheme.gold,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Fila de información con icono, etiqueta y valor
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.subtle, size: AppDimensions.iconSizeS),
        const SizedBox(width: AppDimensions.spacingMD),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppTheme.subtle,
            fontSize: AppDimensions.fontSizeS,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppTheme.text,
              fontSize: AppDimensions.fontSizeS,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}