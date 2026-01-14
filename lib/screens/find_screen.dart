import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/dimensions.dart';
import '../constants/routes.dart';
import '../models/find_user.dart';
import '../models/find_filters.dart';
import '../models/public_user_profile.dart';
import '../navigation/public_profile_args.dart';
import '../navigation/chat_args.dart';
import '../repositories/fake_find_users_repository.dart';
import '../widgets/find/find_search_bar.dart';
import '../widgets/find/filters_button.dart';
import '../widgets/find/find_user_card.dart';
import '../widgets/find/find_filters_bottom_sheet.dart';
import '../widgets/common/app_header.dart';
import '../services/current_user_service.dart';

/// Pantalla para encontrar usuarios/compañeros de idiomas
class FindScreen extends StatefulWidget {
  const FindScreen({super.key});

  @override
  State<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  // BACKEND: Sustituir FakeFindUsersRepository por ApiFindUsersRepository
  // TODO(FE): Inyectar repositorio o usar provider/riverpod para cambiar implementación
  final _repository = FakeFindUsersRepository();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<FindUser> _users = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String _query = '';
  FindFilters _filters = FindFilters.defaults;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreUsers();
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final users = await _repository.searchUsers(
        query: _query,
        filters: _filters,
        page: 0,
      );
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
        _hasMore = users.length >= 10;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar usuarios')),
      );
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final users = await _repository.searchUsers(
        query: _query,
        filters: _filters,
        page: _currentPage,
      );
      if (!mounted) return;
      setState(() {
        _users.addAll(users);
        _isLoadingMore = false;
        _hasMore = users.length >= 10;
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
        _loadUsers();
      }
    });
  }

  Future<void> _onFiltersPressed() async {
    final result = await showFindFiltersBottomSheet(context, _filters);
    if (result != null && mounted) {
      setState(() => _filters = result);
      _loadUsers();
    }
  }

  void _onChat(FindUser user) {
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: ChatArgs(
        otherUserId: user.id,
        prefetchedUser: PublicUserProfile.fromFindUser(user),
      ),
    );
  }

  void _onViewProfile(FindUser user) {
    Navigator.pushNamed(
      context,
      AppRoutes.publicProfile,
      arguments: PublicProfileArgs(
        userId: user.id,
        prefetched: PublicUserProfile.fromFindUser(user),
      ),
    );
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
        onRefresh: _loadUsers,
        color: AppTheme.accent,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Barra de búsqueda y filtros
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingL),
                child: Column(
                  children: [
                    FindSearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: AppDimensions.spacingMD),
                    FiltersButton(
                      onPressed: _onFiltersPressed,
                      hasActiveFilters: _filters.hasActiveFilters,
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
            else if (_users.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: AppTheme.subtle,
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      Text(
                        'No se encontraron usuarios',
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
                      if (index == _users.length) {
                        return _isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(AppDimensions.spacingL),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }
                      final user = _users[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingMD,
                        ),
                        child: FindUserCard(
                          user: user,
                          onChat: () => _onChat(user),
                          onViewProfile: () => _onViewProfile(user),
                        ),
                      );
                    },
                    childCount: _users.length + 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
