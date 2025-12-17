import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Pantalla placeholder para el tab Inicio
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: AppTheme.background,
      ),
      body: Center(
        child: Text(
          'Pantalla de Inicio',
          style: TextStyle(color: AppTheme.text, fontSize: 18),
        ),
      ),
    );
  }
}

