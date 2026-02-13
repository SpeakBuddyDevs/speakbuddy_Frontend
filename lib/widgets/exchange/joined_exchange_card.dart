import 'package:flutter/material.dart';
import '../../models/joined_exchange.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';
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

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormatters.formatExchangeDate(exchange.scheduledAt);
    final participantsStr = exchange.participants
        .map((p) => p.username)
        .where((s) => s.isNotEmpty)
        .join(', ');
    final title = exchange.title ?? 'Intercambio';
    final showLeave = exchange.status == 'SCHEDULED' && onLeave != null;
    final showOpenChat = exchange.status != 'CANCELLED' && onOpenChat != null;

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
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: AppDimensions.fontSizeL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXS),
              Text(
                statusLabel(exchange.status),
                style: TextStyle(
                  color: AppTheme.subtle,
                  fontSize: AppDimensions.fontSizeS,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMD),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Fecha y hora',
                value: dateStr,
              ),
              const SizedBox(height: AppDimensions.spacingMD),
              _InfoRow(
                icon: Icons.access_time_rounded,
                label: 'Duración',
                value: '${exchange.durationMinutes} min',
              ),
              const SizedBox(height: AppDimensions.spacingMD),
              _InfoRow(
                icon: Icons.people_outline_rounded,
                label: 'Participantes',
                value: participantsStr.isNotEmpty ? participantsStr : '—',
              ),
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
                        label: const Text('Abrir chat'),
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
}

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
      children: [
        Icon(icon, color: AppTheme.subtle, size: AppDimensions.iconSizeS),
        const SizedBox(width: AppDimensions.spacingMD),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppTheme.subtle,
            fontSize: AppDimensions.fontSizeS,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppTheme.text,
              fontSize: AppDimensions.fontSizeS,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
