import 'package:flutter/material.dart';
import '../../models/find_user.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Card de usuario para la pantalla Encontrar
class FindUserCard extends StatelessWidget {
  final FindUser user;
  final VoidCallback? onChat;
  final VoidCallback? onViewProfile;

  const FindUserCard({
    super.key,
    required this.user,
    this.onChat,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(
          color: user.isPro ? AppTheme.gold : AppTheme.border,
          width: user.isPro ? 2 : 1,
        ),
      ),
      padding: AppDimensions.paddingCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Info + PRO badge
          Row(
            children: [
              // Avatar con indicador online
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.panel,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: AppTheme.text,
                              fontSize: AppDimensions.fontSizeXL,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (user.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.card, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              // Nombre y país
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        color: AppTheme.text,
                        fontSize: AppDimensions.fontSizeM,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      user.country.isEmpty ? '—' : user.country,
                      style: TextStyle(
                        color: AppTheme.subtle,
                        fontSize: AppDimensions.fontSizeS,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge PRO (esquina derecha, como en la imagen)
              if (user.isPro) _ProBadge(),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Idiomas
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMD,
              vertical: AppDimensions.spacingSM,
            ),
            decoration: BoxDecoration(
              color: AppTheme.panel,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.translate_rounded, size: 16, color: AppTheme.subtle),
                const SizedBox(width: AppDimensions.spacingSM),
                Text(
                  '${user.nativeLanguage.isEmpty ? '—' : user.nativeLanguage} → ${user.targetLanguage.isEmpty ? '—' : user.targetLanguage}',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: AppDimensions.fontSizeS,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Métricas
          Row(
            children: [
              _MetricChip(
                icon: Icons.trending_up_rounded,
                label: 'Nivel ${user.level}',
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              _MetricChip(
                icon: Icons.star_rounded,
                label: user.rating.toStringAsFixed(1),
                iconColor: AppTheme.gold,
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              _MetricChip(
                icon: Icons.chat_bubble_outline_rounded,
                label: '${user.exchanges}',
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          // Botones
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                  ),
                  child: const Text('Chatear'),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewProfile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.text,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMD),
                    side: BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                  ),
                  child: const Text('Ver Perfil'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMD,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.gold,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _MetricChip({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? AppTheme.subtle),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.text,
              fontSize: AppDimensions.fontSizeXS,
            ),
          ),
        ],
      ),
    );
  }
}

