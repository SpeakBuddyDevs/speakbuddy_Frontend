import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pantalla placeholder para el tab Temas
class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Temas'),
        backgroundColor: AppTheme.background,
      ),
      body: Center(
        child: Text(
          'Pantalla de Temas',
          style: TextStyle(color: AppTheme.text, fontSize: 18),
        ),
      ),
    );
  }
}

