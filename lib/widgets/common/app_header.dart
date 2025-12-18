import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Header reutilizable para todas las pantallas principales de la app.
///
/// Muestra:
/// - Badge "SB" a la izquierda
/// - Nombre del usuario y nivel con barra de progreso en el centro-izquierda
/// - Botón "Pro" (si aplica) e icono de notificaciones a la derecha
///
/// BACKEND: Los datos del usuario (nombre, nivel, progreso) deben provenir
/// del endpoint /me o /api/profile del usuario autenticado.
///
/// TODO(BE): Asegurar que el backend expone:
///   - displayName: String
///   - level: int
///   - progressToNextLevel: double (0.0-1.0)
///   - isPro: bool
///
/// TODO(FE): Conectar con CurrentUserService o UsersRepository real.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.userName,
    this.level,
    this.levelProgress,
    this.isPro = false,
    this.onNotificationsTap,
    this.onProTap,
    this.showPro = true,
    this.showNotifications = true,
  });

  /// Nombre del usuario a mostrar.
  /// Si es null, se muestra un placeholder.
  ///
  /// BACKEND: Debe provenir del endpoint /me o /api/profile.
  final String? userName;

  /// Nivel actual del usuario.
  /// Si es null, se muestra nivel 1.
  ///
  /// BACKEND: Debe provenir del endpoint /me o /api/profile.
  final int? level;

  /// Progreso hacia el siguiente nivel (0.0-1.0).
  /// Si es null, se muestra 0.0.
  ///
  /// BACKEND: Debe ser calculado o enviado desde el backend.
  final double? levelProgress;

  /// Indica si el usuario tiene suscripción Pro.
  ///
  /// BACKEND: Debe provenir del endpoint /me o /api/profile.
  final bool isPro;

  /// Callback cuando se toca el icono de notificaciones.
  ///
  /// TODO(BE): Navegar a pantalla de notificaciones o mostrar lista
  /// de notificaciones no leídas desde el endpoint /notifications.
  final VoidCallback? onNotificationsTap;

  /// Callback cuando se toca el botón Pro.
  ///
  /// TODO(BE): Navegar a pantalla de suscripción o mostrar información
  /// de la suscripción Pro desde el endpoint /subscription.
  final VoidCallback? onProTap;

  /// Si se debe mostrar el botón Pro.
  final bool showPro;

  /// Si se debe mostrar el icono de notificaciones.
  final bool showNotifications;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = userName ?? 'Usuario';
    final userLevel = level ?? 1;
    final progress = (levelProgress ?? 0.0).clamp(0.0, 1.0);

    return AppBar(
      backgroundColor: AppTheme.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingL),
        child: Row(
          children: [
            _buildBadge(theme),
            const SizedBox(width: AppDimensions.spacingSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.w600,
                      fontSize: AppDimensions.fontSizeM,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Nivel $userLevel',
                        style: TextStyle(
                          color: AppTheme.subtle,
                          fontSize: AppDimensions.fontSizeXS,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingSM),
                      _ProgressMini(
                        value: progress,
                        track: AppTheme.progressBg,
                        fill: AppTheme.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showPro && isPro) ...[
              _ProButton(onTap: onProTap),
              const SizedBox(width: AppDimensions.spacingSM),
            ],
            if (showNotifications)
              IconButton(
                onPressed: onNotificationsTap ?? _defaultNotificationsTap,
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: AppTheme.subtle,
                ),
                tooltip: 'Notificaciones',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(ThemeData theme) {
    return Container(
      width: AppDimensions.badgeSize,
      height: AppDimensions.badgeSize,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppTheme.border),
      ),
      alignment: Alignment.center,
      child: Text(
        'SB',
        style: TextStyle(
          color: AppTheme.text,
          fontWeight: FontWeight.bold,
          fontSize: AppDimensions.fontSizeM,
        ),
      ),
    );
  }

  void _defaultNotificationsTap() {
    // TODO(BE): Navegar a pantalla de notificaciones o mostrar lista
    // TODO(FE): Implementar navegación real cuando esté disponible
  }
}

/// Botón "Pro" tipo pill con borde y relleno sutil.
class _ProButton extends StatelessWidget {
  const _ProButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? _defaultProTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: AppTheme.gold.withValues(alpha: .12),
          border: Border.all(
            color: AppTheme.gold.withValues(alpha: .5),
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: AppDimensions.iconSizeS,
              color: AppTheme.gold,
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              'Pro',
              style: TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.fontSizeS,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _defaultProTap() {
    // TODO(BE): Navegar a pantalla de suscripción Pro
    // TODO(FE): Implementar navegación real cuando esté disponible
  }
}

/// Barra de progreso mini para el nivel del usuario.
class _ProgressMini extends StatelessWidget {
  const _ProgressMini({
    required this.value,
    required this.track,
    required this.fill,
  });

  final double value;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.progressBarWidth,
      height: AppDimensions.progressBarHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: track,
          valueColor: AlwaysStoppedAnimation<Color>(fill),
        ),
      ),
    );
  }
}

