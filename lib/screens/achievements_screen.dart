import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common/app_header.dart';
import '../services/current_user_service.dart';

/// Pantalla placeholder para el tab Logros
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

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
      body: Center(
        child: Text(
          'Pantalla de Logros',
          style: TextStyle(color: AppTheme.text, fontSize: 18),
        ),
      ),
    );
  }
}

