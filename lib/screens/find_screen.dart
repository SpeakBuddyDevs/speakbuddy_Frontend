import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pantalla placeholder para el tab Encontrar
class FindScreen extends StatelessWidget {
  const FindScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Encontrar'),
        backgroundColor: AppTheme.background,
      ),
      body: Center(
        child: Text(
          'Pantalla de Encontrar',
          style: TextStyle(color: AppTheme.text, fontSize: 18),
        ),
      ),
    );
  }
}

