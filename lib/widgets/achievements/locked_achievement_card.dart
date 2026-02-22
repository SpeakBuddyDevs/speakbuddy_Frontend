import 'package:flutter/material.dart';
import '../../models/achievement.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

class LockedAchievementCard extends StatelessWidget {
  final Achievement achievement;

  const LockedAchievementCard({
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
      child: Row(
        children: [
          // Icono en contenedor cuadrado oscuro
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.panel,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Icon(
              achievement.icon,
              size: 24,
              color: achievement.iconColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMD),
          // Contenido: título, descripción y progreso
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  achievement.title,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                // Descripción
                Text(
                  achievement.description,
                  style: const TextStyle(
                    color: AppTheme.subtle,
                    fontSize: AppDimensions.fontSizeS,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingSM),
                // Barra de progreso con porcentaje
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusCircular,
                        ),
                        child: LinearProgressIndicator(
                          value: achievement.progressPercent,
                          backgroundColor: AppTheme.progressBg,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            achievement.iconColor,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSM),
                    // Porcentaje
                    Text(
                      '${achievement.progressPercentInt}% completado',
                      style: const TextStyle(
                        color: AppTheme.subtle,
                        fontSize: AppDimensions.fontSizeXS,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
