import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pantalla placeholder para el tab Logros
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Logros'),
        backgroundColor: AppTheme.background,
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

