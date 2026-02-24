import 'package:flutter/material.dart';
import '../../models/achievement.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

class UnlockedAchievementCard extends StatelessWidget {
  final Achievement achievement;

  const UnlockedAchievementCard({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono en contenedor cuadrado oscuro
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.panel,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Icon(
              achievement.icon,
              size: 28,
              color: achievement.iconColor,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Title
          Text(
            achievement.displayTitle,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          // Description
          Text(
            achievement.displayDescription,
            style: const TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeXS,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Badge "Desbloqueada"
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSM,
              vertical: AppDimensions.spacingXS,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.green.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  'Unlocked',
                  style: TextStyle(
                    color: Colors.green.shade400,
                    fontSize: AppDimensions.fontSizeXS,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
