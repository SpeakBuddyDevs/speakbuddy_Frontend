import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Modelo para cada item de navegación
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

/// Barra de navegación inferior personalizada con estilo "pill" para el tab activo
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<NavItem> _items = [
    NavItem(icon: Icons.home_rounded, label: 'Home'),
    NavItem(icon: Icons.search_rounded, label: 'Find'),
    NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Topics'),
    NavItem(icon: Icons.emoji_events_outlined, label: 'Achievements'),
    NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.panel,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingSM,
            vertical: AppDimensions.spacingSM,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = index == currentIndex;
              return _NavBarItem(
                icon: item.icon,
                label: item.label,
                isActive: isActive,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.accent : AppTheme.subtle;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSM,
          vertical: AppDimensions.spacingXS,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contenedor "pill" para el icono activo
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? AppDimensions.spacingL : AppDimensions.spacingSM,
                vertical: AppDimensions.spacingSM,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.accent.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
              ),
              child: Icon(
                icon,
                color: color,
                size: AppDimensions.iconSizeM,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: AppDimensions.fontSizeXS,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

