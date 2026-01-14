import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/dimensions.dart';
import '../constants/routes.dart';
import '../models/public_exchange.dart';
import '../models/public_exchange_filters.dart';
import '../repositories/fake_public_exchanges_repository.dart';
import '../widgets/find/filters_button.dart';
import '../widgets/find/find_search_bar.dart';
import '../widgets/public_exchanges/public_exchange_card.dart';
import '../widgets/public_exchanges/public_exchange_filters_bottom_sheet.dart';
import '../widgets/common/app_header.dart';
import '../widgets/navigation/app_bottom_nav_bar.dart';
import '../services/current_user_service.dart';
import '../navigation/public_profile_args.dart';

/// Pantalla para ver y unirse a intercambios públicos (sesiones grupales)
class PublicExchangesScreen extends StatefulWidget {
  const PublicExchangesScreen({super.key});

  @override
  State<PublicExchangesScreen> createState() => _PublicExchangesScreenState();
}

class _PublicExchangesScreenState extends State<PublicExchangesScreen> {
  // BACKEND: Sustituir FakePublicExchangesRepository por ApiPublicExchangesRepository
  // TODO(FE): Inyectar repositorio o usar provider/riverpod para cambiar implementación
  final _repository = FakePublicExchangesRepository();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  List<PublicExchange> _exchanges = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String _query = '';
  PublicExchangeFilters _filters = PublicExchangeFilters.defaults;
  Timer? _debounce;
  final Set<String> _joinedExchangeIds = {}; // IDs de intercambios a los que el usuario se ha unido
  final Map<String, int> _additionalParticipants = {}; // Participantes adicionales añadidos localmente por intercambio

  @override
  void initState() {
    super.initState();
    _loadExchanges();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreExchanges();
    }
  }

  Future<void> _loadExchanges() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final exchanges = await _repository.searchExchanges(
        query: _query,
        filters: _filters,
        page: 0,
      );
      if (!mounted) return;
      setState(() {
        _exchanges = exchanges;
        _isLoading = false;
        _hasMore = exchanges.length >= 10;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar intercambios')),
      );
    }
  }

  Future<void> _loadMoreExchanges() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final exchanges = await _repository.searchExchanges(
        query: _query,
        filters: _filters,
        page: _currentPage,
      );
      if (!mounted) return;
      setState(() {
        _exchanges.addAll(exchanges);
        _isLoadingMore = false;
        _hasMore = exchanges.length >= 10;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (_query != value) {
        _query = value;
        _loadExchanges();
      }
    });
  }

  Future<void> _onFiltersPressed() async {
    final result = await showPublicExchangeFiltersBottomSheet(context, _filters);
    if (result != null && mounted) {
      setState(() => _filters = result);
      _loadExchanges();
    }
  }

  void _onJoin(PublicExchange exchange) {
    if (exchange.isEligible) {
      // Marcar como unido y actualizar contador de participantes
      setState(() {
        _joinedExchangeIds.add(exchange.id);
        // Incrementar contador de participantes localmente
        _additionalParticipants[exchange.id] = (_additionalParticipants[exchange.id] ?? 0) + 1;
      });
      
      // TODO(FE): Implementar lógica de unirse al intercambio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te has unido a "${exchange.title}"')),
      );
    } else {
      // TODO(FE): Implementar lógica de solicitar unirse
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitando unirse a "${exchange.title}"...')),
      );
    }
  }
  
  /// Obtiene el número actualizado de participantes para un intercambio
  int _getCurrentParticipants(PublicExchange exchange) {
    final additional = _additionalParticipants[exchange.id] ?? 0;
    return exchange.currentParticipants + additional;
  }

  Future<void> _onLeave(PublicExchange exchange) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('Abandonar intercambio'),
        content: const Text('¿Estás seguro de que quieres abandonar este intercambio?'),
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

    if (confirm == true && mounted) {
      setState(() {
        // Remover del Set de intercambios unidos
        _joinedExchangeIds.remove(exchange.id);
        // Decrementar contador de participantes si existe
        if (_additionalParticipants.containsKey(exchange.id) && 
            _additionalParticipants[exchange.id]! > 0) {
          _additionalParticipants[exchange.id] = 
              _additionalParticipants[exchange.id]! - 1;
          // Si llega a 0, remover la entrada
          if (_additionalParticipants[exchange.id] == 0) {
            _additionalParticipants.remove(exchange.id);
          }
        }
      });

      // TODO(FE): Implementar lógica de abandonar intercambio en backend
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Has abandonado "${exchange.title}"')),
        );
      }
    }
  }

  void _onCreateExchange() {
    Navigator.pushNamed(
      context,
      AppRoutes.createExchange,
    ).then((created) {
      // Si se creó un intercambio, recargar la lista
      if (created == true) {
        _loadExchanges();
      }
    });
  }

  void _onDetails(PublicExchange exchange) {
    Navigator.pushNamed(
      context,
      AppRoutes.publicProfile,
      arguments: PublicProfileArgs(
        userId: exchange.creatorId,
        prefetched: null, // Se cargará desde el repositorio
      ),
    );
  }

  void _onTabTapped(int index) {
    // Si se toca el tab de "Encontrar" (índice 1), simplemente volver
    if (index == 1) {
      Navigator.of(context).pop();
    } else {
      // Para otros tabs, volver al MainShell y cambiar al tab correspondiente
      // Buscar el MainShell en la pila de navegación
      Navigator.of(context).popUntil((route) {
        return route.settings.name == AppRoutes.main || route.isFirst;
      });
      
      // Navegar al MainShell con el nuevo índice
      // Usar Future.microtask para asegurar que el pop se complete primero
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.main,
            arguments: index,
          );
        }
      });
    }
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
        onRefresh: _loadExchanges,
        color: AppTheme.accent,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header con título, subtítulo y filtros
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: AppTheme.text,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Intercambios Públicos',
                                style: TextStyle(
                                  color: AppTheme.text,
                                  fontSize: AppDimensions.fontSizeXL,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingXS),
                              Text(
                                'Únete a sesiones grupales',
                                style: TextStyle(
                                  color: AppTheme.subtle,
                                  fontSize: AppDimensions.fontSizeS,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingMD),
                    FindSearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      hintText: 'Buscar intercambios...',
                    ),
                    const SizedBox(height: AppDimensions.spacingMD),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _onCreateExchange,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Crear intercambio'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.spacingMD,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingMD),
                        FiltersButton(
                          onPressed: _onFiltersPressed,
                          hasActiveFilters: _filters.hasActiveFilters,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Contenido
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_exchanges.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        size: 64,
                        color: AppTheme.subtle,
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      Text(
                        'No se encontraron intercambios',
                        style: TextStyle(
                          color: AppTheme.subtle,
                          fontSize: AppDimensions.fontSizeM,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingL,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _exchanges.length) {
                        return _isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(AppDimensions.spacingL),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }
                      final exchange = _exchanges[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingMD,
                        ),
                        child: PublicExchangeCard(
                          exchange: exchange,
                          isJoined: _joinedExchangeIds.contains(exchange.id),
                          currentParticipantsOverride: _getCurrentParticipants(exchange),
                          onJoin: () => _onJoin(exchange),
                          onDetails: () => _onDetails(exchange),
                          onLeave: () => _onLeave(exchange),
                        ),
                      );
                    },
                    childCount: _exchanges.length + 1,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1, // Tab "Encontrar" está activo
        onTap: _onTabTapped,
      ),
    );
  }
}
