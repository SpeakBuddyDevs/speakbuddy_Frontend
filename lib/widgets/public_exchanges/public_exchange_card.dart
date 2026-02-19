import 'package:flutter/material.dart';
import '../../models/public_exchange.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Card de intercambio público para la pantalla de Intercambios Públicos
class PublicExchangeCard extends StatelessWidget {
  final PublicExchange exchange;
  final bool isJoined; // Si el usuario se ha unido a este intercambio
  final int? currentParticipantsOverride; // Contador de participantes actualizado (opcional)
  final VoidCallback? onJoin;
  final VoidCallback? onDetails;
  final VoidCallback? onLeave; // Callback para abandonar el intercambio

  const PublicExchangeCard({
    super.key,
    required this.exchange,
    this.isJoined = false,
    this.currentParticipantsOverride,
    this.onJoin,
    this.onDetails,
    this.onLeave,
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
          // Header: Avatar + Título + Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar del creador
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.panel,
                backgroundImage: exchange.creatorAvatarUrl != null
                    ? NetworkImage(exchange.creatorAvatarUrl!)
                    : null,
                child: exchange.creatorAvatarUrl == null
                    ? Text(
                        exchange.creatorName.isNotEmpty
                            ? exchange.creatorName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: AppDimensions.fontSizeL,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              // Título y creador
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exchange.title,
                      style: TextStyle(
                        color: AppTheme.text,
                        fontSize: AppDimensions.fontSizeM,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      'Por ${exchange.creatorName}',
                      style: TextStyle(
                        color: AppTheme.subtle,
                        fontSize: AppDimensions.fontSizeS,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge "No elegible"
              if (!exchange.isEligible) ...[
                const SizedBox(width: AppDimensions.spacingSM),
                _NotEligibleBadge(),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Descripción
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
          // Intercambio bidireccional de idiomas
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
                Text(
                  '${exchange.nativeLanguage} ↔ ${exchange.targetLanguage}',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: AppDimensions.fontSizeS,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Tags: Nivel, Fecha
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
          // Tags: Duración, Participantes
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
              // Badge "Lleno" cuando está completo
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
                        'Lleno',
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
          // Detalles adicionales: Nivel mínimo y idiomas
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: AppDimensions.iconSizeS,
                color: AppTheme.gold,
              ),
              const SizedBox(width: AppDimensions.spacingXS),
              Text(
                'Nivel ${exchange.minLevel}+',
                style: TextStyle(
                  color: AppTheme.subtle,
                  fontSize: AppDimensions.fontSizeS,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.subtle,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              Text(
                'Ofrece: ${exchange.nativeLanguage}',
                style: TextStyle(
                  color: AppTheme.subtle,
                  fontSize: AppDimensions.fontSizeS,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.subtle,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              Text(
                'Busca: ${exchange.targetLanguage}',
                style: TextStyle(
                  color: AppTheme.subtle,
                  fontSize: AppDimensions.fontSizeS,
                ),
              ),
            ],
          ),
          // Temas/categorías (solo si hay temas)
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
          // Plataformas de videollamada
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
                      : 'Plataforma por acordar',
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
          // Caja de requisitos no cumplidos
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
                    'No cumples estos requisitos:',
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
                                req,
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
          // Botones
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
                        child: const Text('Te has unido'),
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
                            child: const Text('Solicitud enviada'),
                          )
                        : ElevatedButton(
                            onPressed: isFull ? null : onJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFull
                                  ? AppTheme.panel
                                  : (exchange.isEligible
                                      ? AppTheme.accent
                                      : AppTheme.card),
                              foregroundColor: isFull
                                  ? AppTheme.subtle
                                  : (exchange.isEligible
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
                                      : (exchange.isEligible
                                          ? AppTheme.accent
                                          : AppTheme.border),
                                ),
                              ),
                            ),
                            child: Text(
                              isFull
                                  ? 'Lleno'
                                  : (exchange.isEligible ? 'Unirse' : 'Solicitar unirse'),
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
                  child: const Text('Ver perfil'),
                ),
              ),
            ],
          ),
        ],
      ),
        ),
        // Icono rojo para abandonar intercambio (solo cuando está unido)
        if (isJoined && onLeave != null)
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
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];

    final weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    // Si es hoy
    if (dateOnly == today) {
      return 'Hoy, $timeStr';
    }
    // Si es mañana
    if (dateOnly == tomorrow) {
      return 'Mañana, $timeStr';
    }
    // Si es pasado mañana
    if (dateOnly == dayAfterTomorrow) {
      return 'Pasado mañana, $timeStr';
    }
    // Si es esta semana (dentro de 7 días)
    final daysDiff = dateOnly.difference(today).inDays;
    if (daysDiff > 0 && daysDiff <= 7) {
      final weekday = weekdays[date.weekday - 1];
      return '$weekday ${date.day} ${months[date.month - 1]}, $timeStr';
    }
    // Para fechas más lejanas (mostrar año solo si es diferente al actual)
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
