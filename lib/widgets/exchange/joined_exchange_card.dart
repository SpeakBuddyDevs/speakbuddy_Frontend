import 'package:flutter/material.dart';
import '../../models/joined_exchange.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';
import '../../constants/countries.dart';
import '../../utils/date_formatters.dart';

/// Tarjeta que muestra un intercambio (JoinedExchange).
/// Usada en HomeScreen y ExchangeHistoryScreen.
class JoinedExchangeCard extends StatelessWidget {
  final JoinedExchange exchange;
  final Future<void> Function(JoinedExchange)? onConfirm;
  final VoidCallback? onLeave;
  final VoidCallback? onOpenChat;
  final bool hasNewMessages;

  const JoinedExchangeCard({
    super.key,
    required this.exchange,
    this.onConfirm,
    this.onLeave,
    this.onOpenChat,
    this.hasNewMessages = false,
  });

  static String statusLabel(String status) {
    switch (status) {
      case 'SCHEDULED':
        return 'Programado';
      case 'ENDED_PENDING_CONFIRMATION':
        return 'Pendiente de confirmar';
      case 'COMPLETED':
        return 'Completado';
      case 'CANCELLED':
        return 'Cancelado';
      default:
        return status;
    }
  }

  JoinedExchangeParticipant? _getCreator() {
    return exchange.participants
        .where((p) => p.role == 'creator')
        .firstOrNull;
  }

  List<JoinedExchangeParticipant> _getJoinedParticipants() {
    return exchange.participants
        .where((p) => p.role != 'creator')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormatters.formatExchangeDate(exchange.scheduledAt);
    final showLeave = exchange.status == 'SCHEDULED' && onLeave != null;
    final showOpenChat = exchange.status != 'CANCELLED' && onOpenChat != null;
    final useTitleHeader = exchange.status != 'CANCELLED';
    final creator = _getCreator();
    final joinedParticipants = _getJoinedParticipants();

    final languagesStr = _buildLanguagesString();
    final platformsStr = exchange.platforms.isNotEmpty
        ? exchange.platforms.join(', ')
        : 'No especificada';
    final participantsCountStr = _buildParticipantsCountString();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(color: AppTheme.border),
          ),
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con avatar del creador, nombre, PRO badge, rating y país
              _ParticipantHeader(
                participant: creator,
                exchangeTitle: exchange.title,
                showTitleAndByLine: useTitleHeader,
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Filas de información
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Date and time',
                value: dateStr,
              ),
              const SizedBox(height: AppDimensions.spacingMD),
              _InfoRow(
                icon: Icons.videocam_outlined,
                label: 'Platform',
                value: platformsStr,
              ),
              const SizedBox(height: AppDimensions.spacingMD),
              _InfoRow(
                icon: Icons.translate_outlined,
                label: 'Language and duration',
                value: '$languagesStr • ${exchange.durationMinutes} min',
              ),
              // Tema (solo si hay topics configurados)
              if (exchange.topics.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingMD),
                _InfoRow(
                  icon: Icons.description_outlined,
                  label: 'Topic',
                  value: exchange.topics.join(', '),
                ),
              ],

              // Participantes unidos
              if (joinedParticipants.isNotEmpty || participantsCountStr.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingMD),
                _ParticipantsRow(
                  participants: joinedParticipants,
                  countLabel: participantsCountStr,
                ),
              ],

              // Button: Open chat
              if (showOpenChat) ...[
                const SizedBox(height: AppDimensions.spacingL),
                Row(
                  children: [
                    if (hasNewMessages)
                      Padding(
                        padding: const EdgeInsets.only(right: AppDimensions.spacingSM),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingSM,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            border: Border.all(color: AppTheme.accent),
                          ),
                          child: Text(
                            'Nuevos',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: AppDimensions.fontSizeXS,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onOpenChat,
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text('Open chat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.text,
                          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMD),
                          side: BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Botón Confirmar intercambio
              if (exchange.canConfirm && onConfirm != null) ...[
                const SizedBox(height: AppDimensions.spacingL),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => onConfirm!(exchange),
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Confirmar intercambio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Botón abandonar
        if (showLeave)
          Positioned(
            top: AppDimensions.spacingSM,
            right: AppDimensions.spacingSM,
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
              color: Colors.redAccent,
              iconSize: 24,
              onPressed: onLeave,
              tooltip: 'Abandonar intercambio',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.card.withValues(alpha: 0.9),
                padding: const EdgeInsets.all(AppDimensions.spacingXS),
              ),
            ),
          ),
      ],
    );
  }

  String _buildLanguagesString() {
    final native = exchange.nativeLanguage;
    final target = exchange.targetLanguage;
    if (native != null && target != null) {
      return '$native - $target';
    } else if (native != null) {
      return native;
    } else if (target != null) {
      return target;
    }
    return 'Not specified';
  }

  String _buildParticipantsCountString() {
    final current = exchange.participants.length;
    final max = exchange.maxParticipants;
    if (max != null) {
      if (current >= max) {
        return '$current/$max (full)';
      }
      return '$current/$max';
    }
    return '$current participants';
  }
}

/// Header con avatar, nombre/título, badge PRO, rating y país del creador
class _ParticipantHeader extends StatelessWidget {
  final JoinedExchangeParticipant? participant;
  final String? exchangeTitle;
  final bool showTitleAndByLine;

  const _ParticipantHeader({
    required this.participant,
    this.exchangeTitle,
    this.showTitleAndByLine = false,
  });

  @override
  Widget build(BuildContext context) {
    if (participant == null) {
      return const SizedBox.shrink();
    }

    final p = participant!;
    final initials = p.username.isNotEmpty
        ? p.username.substring(0, 1).toUpperCase()
        : '?';
    final hasAvatar = p.avatarUrl != null && p.avatarUrl!.isNotEmpty;

    return Row(
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.accent.withValues(alpha: 0.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasAvatar
              ? Image.network(
                  p.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildInitials(initials),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildInitials(initials);
                  },
                )
              : _buildInitials(initials),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        // Nombre/título, país, rating y badges
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitleAndByLine) ...[
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        (exchangeTitle != null && exchangeTitle!.isNotEmpty)
                            ? exchangeTitle!
                            : p.username,
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: AppDimensions.fontSizeM,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (p.isPro) ...[
                      const SizedBox(width: AppDimensions.spacingSM),
                      const _ProBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                _buildByCreatorAndRating(p),
              ] else ...[
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        p.username,
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: AppDimensions.fontSizeM,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (p.isPro) ...[
                      const SizedBox(width: AppDimensions.spacingSM),
                      const _ProBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                _buildCountryAndRating(p),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: AppTheme.accent,
          fontSize: AppDimensions.fontSizeL,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCountryAndRating(JoinedExchangeParticipant p) {
    final hasCountry = p.country != null && p.country!.isNotEmpty;
    final hasRating = p.rating != null && p.rating! > 0;

    if (!hasCountry && !hasRating) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (hasCountry)
          Text(
            AppCountries.displayName(p.country),
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
            ),
          ),
        if (hasCountry && hasRating)
          Text(
            ' - ',
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
            ),
          ),
        if (hasRating) ...[
          Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 14,
          ),
          const SizedBox(width: 2),
          Text(
            p.rating!.toStringAsFixed(1),
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildByCreatorAndRating(JoinedExchangeParticipant p) {
    final hasRating = p.rating != null && p.rating! > 0;

    return Row(
      children: [
        Text(
          'By ${p.username}',
          style: TextStyle(
            color: AppTheme.subtle,
            fontSize: AppDimensions.fontSizeS,
          ),
        ),
        if (hasRating) ...[
          Text(
            ' - ',
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
            ),
          ),
          Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 14,
          ),
          const SizedBox(width: 2),
          Text(
            p.rating!.toStringAsFixed(1),
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

/// Fila de participantes unidos con contador
class _ParticipantsRow extends StatelessWidget {
  final List<JoinedExchangeParticipant> participants;
  final String countLabel;

  const _ParticipantsRow({
    required this.participants,
    required this.countLabel,
  });

  @override
  Widget build(BuildContext context) {
    final names = participants.map((p) => p.username).join(', ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono con fondo circular
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.people_outline_rounded, color: AppTheme.accent, size: 20),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        // Textos verticales
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Participants',
                    style: TextStyle(
                      color: AppTheme.subtle,
                      fontSize: AppDimensions.fontSizeXS,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: countLabel.contains('lleno')
                          ? Colors.orange.withValues(alpha: 0.2)
                          : AppTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Text(
                      countLabel,
                      style: TextStyle(
                        color: countLabel.contains('lleno')
                            ? Colors.orange
                            : AppTheme.accent,
                        fontSize: AppDimensions.fontSizeXS,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                names.isNotEmpty ? names : 'Solo tú',
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: AppDimensions.fontSizeS,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Badge PRO
class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Fila de información con icono circular
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono con fondo circular
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.accent, size: 20),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        // Textos verticales
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.subtle,
                  fontSize: AppDimensions.fontSizeXS,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: AppDimensions.fontSizeS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
