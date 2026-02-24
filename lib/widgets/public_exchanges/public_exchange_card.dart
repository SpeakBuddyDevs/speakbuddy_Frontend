import 'package:flutter/material.dart';
import '../../models/public_exchange.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';
import '../../utils/requirement_display.dart';
import '../password_input_dialog.dart';

/// Card de intercambio público para la pantalla de Intercambios Públicos
class PublicExchangeCard extends StatelessWidget {
  final PublicExchange exchange;
  final bool isJoined; // Si el usuario se ha unido a este intercambio
  final int? currentParticipantsOverride; // Contador de participantes actualizado (opcional)
  final VoidCallback? onJoin;
  final VoidCallback? onDetails;
  final VoidCallback? onLeave; // Callback para abandonar el intercambio
  final void Function(String password)? onJoinWithPassword; // Callback para unirse con contraseña (intercambios privados)

  const PublicExchangeCard({
    super.key,
    required this.exchange,
    this.isJoined = false,
    this.currentParticipantsOverride,
    this.onJoin,
    this.onDetails,
    this.onLeave,
    this.onJoinWithPassword,
  });

  @override
  Widget build(BuildContext context) {
    // Borde amarillo suave para intercambios PRO
    final borderColor = exchange.creatorIsPro
        ? AppTheme.gold.withValues(alpha: 0.6)
        : AppTheme.border;
    
    // Calcular participantes actuales y si está lleno
    final currentParticipants = currentParticipantsOverride ?? exchange.currentParticipants;
    final isFull = _isFull(currentParticipants, exchange.maxParticipants);
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(color: borderColor),
          ),
          padding: AppDimensions.paddingCard,
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Title + Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Creator avatar
              _CreatorAvatar(
                avatarUrl: exchange.creatorAvatarUrl,
                creatorName: exchange.creatorName,
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              // Title and creator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!exchange.isPublic) ...[
                          Icon(
                            Icons.lock_rounded,
                            size: 16,
                            color: AppTheme.subtle,
                          ),
                          const SizedBox(width: AppDimensions.spacingXS),
                        ],
                        Expanded(
                          child: Text(
                            exchange.title,
                            style: TextStyle(
                              color: AppTheme.text,
                              fontSize: AppDimensions.fontSizeM,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      'By ${exchange.creatorName}',
                      style: TextStyle(
                        color: AppTheme.subtle,
                        fontSize: AppDimensions.fontSizeS,
                      ),
                    ),
                  ],
                ),
              ),
              // \"Not eligible\" badge
              if (!exchange.isEligible) ...[
                const SizedBox(width: AppDimensions.spacingSM),
                _NotEligibleBadge(),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Description
          Text(
            exchange.description,
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Bidirectional language exchange
          if (exchange.nativeLanguage.isNotEmpty || exchange.targetLanguage.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMD,
                vertical: AppDimensions.spacingSM,
              ),
              decoration: BoxDecoration(
                color: AppTheme.panel,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: AppTheme.accent),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 16,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: AppDimensions.spacingSM),
                  Flexible(
                    child: Text(
                      '${exchange.nativeLanguage} ↔ ${exchange.targetLanguage}',
                      style: TextStyle(
                        color: AppTheme.text,
                        fontSize: AppDimensions.fontSizeS,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Tags: Level, Date
          Wrap(
            spacing: AppDimensions.spacingSM,
            runSpacing: AppDimensions.spacingSM,
            children: [
              _InfoTag(
                icon: Icons.person_rounded,
                label: exchange.requiredLevel,
                borderColor: Colors.green,
              ),
              _InfoTag(
                icon: Icons.calendar_today_rounded,
                label: _formatDate(exchange.date),
                borderColor: AppTheme.border,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          // Tags: Duration, Participants
          Wrap(
            spacing: AppDimensions.spacingSM,
            runSpacing: AppDimensions.spacingSM,
            children: [
              _InfoTag(
                icon: Icons.access_time_rounded,
                label: '${exchange.durationMinutes}min',
                borderColor: AppTheme.border,
              ),
              _InfoTag(
                icon: Icons.group_rounded,
                label: '$currentParticipants/${exchange.maxParticipants}',
                borderColor: isFull ? Colors.orange : AppTheme.border,
              ),
              // \"Full\" badge when full
              if (isFull)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSM,
                    vertical: AppDimensions.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        size: 12,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Full',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: AppDimensions.fontSizeXS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Extra details: minimum level and languages
          Wrap(
            spacing: AppDimensions.spacingSM,
            runSpacing: AppDimensions.spacingXS,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: AppDimensions.iconSizeS,
                    color: AppTheme.gold,
                  ),
                  const SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    'Level ${exchange.minLevel}+',
                    style: TextStyle(
                      color: AppTheme.subtle,
                      fontSize: AppDimensions.fontSizeS,
                    ),
                  ),
                ],
              ),
              if (exchange.nativeLanguage.isNotEmpty) ...[
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.subtle,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  'Offers: ${exchange.nativeLanguage}',
                  style: TextStyle(
                    color: AppTheme.subtle,
                    fontSize: AppDimensions.fontSizeS,
                  ),
                ),
              ],
              if (exchange.targetLanguage.isNotEmpty) ...[
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.subtle,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  'Looking for: ${exchange.targetLanguage}',
                  style: TextStyle(
                    color: AppTheme.subtle,
                    fontSize: AppDimensions.fontSizeS,
                  ),
                ),
              ],
            ],
          ),
          // Topics/categories (only if present)
          if (exchange.topics != null && exchange.topics!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSM),
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: AppDimensions.iconSizeS,
                  color: AppTheme.subtle,
                ),
                const SizedBox(width: AppDimensions.spacingXS),
                Expanded(
                  child: Text(
                    exchange.topics!.join(', '),
                    style: TextStyle(
                      color: AppTheme.subtle,
                      fontSize: AppDimensions.fontSizeS,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          // Video platforms
          const SizedBox(height: AppDimensions.spacingSM),
          Row(
            children: [
              Icon(
                Icons.videocam_rounded,
                size: AppDimensions.iconSizeS,
                color: AppTheme.subtle,
              ),
              const SizedBox(width: AppDimensions.spacingXS),
              Expanded(
                child: Text(
                  exchange.platforms != null && exchange.platforms!.isNotEmpty
                      ? exchange.platforms!.join(', ')
                      : 'Platform to be agreed',
                  style: TextStyle(
                    color: AppTheme.subtle,
                    fontSize: AppDimensions.fontSizeS,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Box for unmet requirements
          if (!exchange.isEligible && exchange.unmetRequirements != null && exchange.unmetRequirements!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMD),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMD),
              decoration: BoxDecoration(
                color: AppTheme.panel,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(color: AppTheme.gold),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You do not meet these requirements:',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: AppDimensions.fontSizeS,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSM),
                  ...exchange.unmetRequirements!.map((req) => Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spacingXS),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: AppTheme.gold,
                            ),
                            const SizedBox(width: AppDimensions.spacingSM),
                            Expanded(
                              child: Text(
                                translateRequirement(req),
                                style: TextStyle(
                                  color: AppTheme.gold,
                                  fontSize: AppDimensions.fontSizeS,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.spacingL),
          // Buttons
          Row(
            children: [
              Expanded(
                child: isJoined
                    ? ElevatedButton(
                        onPressed: null, // Deshabilitado cuando está unido
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.panel,
                          foregroundColor: AppTheme.subtle,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.spacingMD,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                            side: BorderSide(color: AppTheme.border),
                          ),
                        ),
                        child: const Text('Joined'),
                      )
                    : exchange.hasPendingJoinRequest
                        ? ElevatedButton(
                            onPressed: null, // Deshabilitado: ya envió solicitud
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.panel,
                              foregroundColor: AppTheme.subtle,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.spacingMD,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                                side: BorderSide(color: AppTheme.border),
                              ),
                            ),
                            child: const Text('Request sent'),
                          )
                        : ElevatedButton(
                            onPressed: isFull ? null : () => _handleJoin(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFull
                                  ? AppTheme.panel
                                  : (exchange.isEligible || !exchange.isPublic
                                      ? AppTheme.accent
                                      : AppTheme.card),
                              foregroundColor: isFull
                                  ? AppTheme.subtle
                                  : (exchange.isEligible || !exchange.isPublic
                                      ? Colors.white
                                      : AppTheme.text),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.spacingMD,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                                side: BorderSide(
                                  color: isFull
                                      ? AppTheme.border
                                      : (exchange.isEligible || !exchange.isPublic
                                          ? AppTheme.accent
                                          : AppTheme.border),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!exchange.isPublic) ...[
                                  Icon(Icons.lock_rounded, size: 16),
                                  const SizedBox(width: AppDimensions.spacingXS),
                                ],
                                Text(
                                  isFull
                                      ? 'Full'
                                      : (!exchange.isPublic
                                          ? 'Join'
                                          : (exchange.isEligible ? 'Join' : 'Request to join')),
                                ),
                              ],
                            ),
                          ),
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetails,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.text,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingMD,
                    ),
                    side: BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                  ),
                  child: const Text('View profile'),
                ),
              ),
            ],
          ),
        ],
      ),
        ),
        // Red icon to leave exchange (only when joined)
        if (isJoined && onLeave != null)
          Positioned(
            top: AppDimensions.spacingSM,
            right: AppDimensions.spacingSM,
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
              color: Colors.redAccent,
              iconSize: 24,
              onPressed: onLeave,
              tooltip: 'Leave exchange',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.card.withValues(alpha: 0.9),
                padding: const EdgeInsets.all(AppDimensions.spacingXS),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleJoin(BuildContext context) async {
    if (!exchange.isPublic) {
      final password = await showPasswordInputDialog(context);
      if (password != null && password.isNotEmpty) {
        onJoinWithPassword?.call(password);
      }
    } else {
      onJoin?.call();
    }
  }

  bool _isFull(int current, int max) {
    return current >= max;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    // Today
    if (dateOnly == today) {
      return 'Today, $timeStr';
    }
    // Tomorrow
    if (dateOnly == tomorrow) {
      return 'Tomorrow, $timeStr';
    }
    // The day after tomorrow
    if (dateOnly == dayAfterTomorrow) {
      return 'The day after tomorrow, $timeStr';
    }
    // Within this week (next 7 days)
    final daysDiff = dateOnly.difference(today).inDays;
    if (daysDiff > 0 && daysDiff <= 7) {
      final weekday = weekdays[date.weekday - 1];
      return '$weekday ${date.day} ${months[date.month - 1]}, $timeStr';
    }
    // For later dates (show year only if different)
    if (date.year != now.year) {
      return '${date.day} ${months[date.month - 1]} ${date.year}, $timeStr';
    }
    return '${date.day} ${months[date.month - 1]}, $timeStr';
  }
}

class _NotEligibleBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: AppTheme.gold),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: AppTheme.gold,
          ),
          const SizedBox(width: 4),
          Text(
            'No elegible',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: AppDimensions.fontSizeXS,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color borderColor;

  const _InfoTag({
    required this.icon,
    required this.label,
    required this.borderColor,
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
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.text,
          ),
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

class _CreatorAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String creatorName;

  const _CreatorAvatar({
    required this.avatarUrl,
    required this.creatorName,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;
    final initials = creatorName.isNotEmpty
        ? creatorName[0].toUpperCase()
        : '?';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.panel,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasAvatar
          ? Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildInitials(initials),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildInitials(initials);
              },
            )
          : _buildInitials(initials),
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: AppTheme.text,
          fontSize: AppDimensions.fontSizeL,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
