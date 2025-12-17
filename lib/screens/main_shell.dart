import 'package:flutter/material.dart';
import '../widgets/navigation/app_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'find_screen.dart';
import 'topics_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';

/// Contenedor principal con navegación por tabs.
/// Usa IndexedStack para mantener el estado de cada pantalla.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Lista de pantallas para cada tab
  final List<Widget> _screens = const [
    HomeScreen(),
    FindScreen(),
    TopicsScreen(),
    AchievementsScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

