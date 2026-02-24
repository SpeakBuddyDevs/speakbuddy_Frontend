import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../constants/dimensions.dart';
import '../theme/app_theme.dart';
import '../widgets/common/app_header.dart';
import '../widgets/achievements/unlocked_achievement_card.dart';
import '../widgets/achievements/locked_achievement_card.dart';
import '../services/current_user_service.dart';
import '../repositories/api_achievements_repository.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _userService = CurrentUserService();
  final _achievementsRepository = ApiAchievementsRepository();

  List<Achievement> _unlockedAchievements = [];
  List<Achievement> _lockedAchievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      final unlocked = await _achievementsRepository.getUnlockedAchievements();
      final locked = await _achievementsRepository.getLockedAchievements();

      if (mounted) {
        setState(() {
          _unlockedAchievements = unlocked;
          _lockedAchievements = locked;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppHeader(
        userName: _userService.getDisplayName(),
        level: _userService.getLevel(),
        levelProgress: _userService.getProgressToNextLevel(),
        isPro: _userService.isPro(),
        avatarUrl: _userService.getAvatarUrl(),
        onNotificationsTap: () {
          Navigator.pushNamed(context, AppRoutes.notifications);
        },
        onProTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pro coming soon')),
          );
        },
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            )
          : RefreshIndicator(
              onRefresh: _loadAchievements,
              color: AppTheme.accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppDimensions.paddingScreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección: Medallas Desbloqueadas
                    _buildSectionHeader(
                      icon: Icons.emoji_events_rounded,
                      iconColor: AppTheme.gold,
                      title: 'Unlocked Badges',
                      count: _unlockedAchievements.length,
                    ),
                    const SizedBox(height: AppDimensions.spacingMD),
                    _buildUnlockedGrid(),
                    const SizedBox(height: AppDimensions.spacingXXXL),
                    // Sección: Por Desbloquear
                    _buildSectionHeader(
                      icon: Icons.lock_rounded,
                      iconColor: AppTheme.subtle,
                      title: 'To Unlock',
                      count: _lockedAchievements.length,
                    ),
                    const SizedBox(height: AppDimensions.spacingMD),
                    _buildLockedList(),
                    const SizedBox(height: AppDimensions.spacingL),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: AppDimensions.spacingSM),
        Text(
          '$title ($count)',
          style: const TextStyle(
            color: AppTheme.text,
            fontSize: AppDimensions.fontSizeL,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockedGrid() {
    if (_unlockedAchievements.isEmpty) {
      return _buildEmptyState('You have not unlocked any badges yet');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.spacingMD,
        mainAxisSpacing: AppDimensions.spacingMD,
        childAspectRatio: 0.85,
      ),
      itemCount: _unlockedAchievements.length,
      itemBuilder: (context, index) {
        return UnlockedAchievementCard(
          achievement: _unlockedAchievements[index],
        );
      },
    );
  }

  Widget _buildLockedList() {
    // Si ambas listas están vacías, probablemente hay un error de carga
    if (_lockedAchievements.isEmpty && _unlockedAchievements.isEmpty) {
      return _buildEmptyState('No achievements found');
    }

    if (_lockedAchievements.isEmpty) {
      return _buildEmptyState('You have unlocked all achievements!');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _lockedAchievements.length,
      separatorBuilder: (context, index) => const SizedBox(
        height: AppDimensions.spacingMD,
      ),
      itemBuilder: (context, index) {
        return LockedAchievementCard(
          achievement: _lockedAchievements[index],
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXXXL),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppTheme.border),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: AppTheme.subtle,
            fontSize: AppDimensions.fontSizeS,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
