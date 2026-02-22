import 'package:flutter/material.dart';
import '../constants/dimensions.dart';
import '../constants/routes.dart';
import '../navigation/rate_participants_args.dart';
import '../theme/app_theme.dart';
import '../widgets/rate_user_dialog.dart';

class RateParticipantsScreen extends StatefulWidget {
  final RateParticipantsArgs args;

  const RateParticipantsScreen({super.key, required this.args});

  @override
  State<RateParticipantsScreen> createState() => _RateParticipantsScreenState();
}

class _RateParticipantsScreenState extends State<RateParticipantsScreen> {
  final Set<String> _ratedUserIds = {};

  void _onRateUser(RateParticipantInfo participant) async {
    final result = await showRateUserDialog(
      context,
      userId: participant.userId,
      userName: participant.username,
      avatarUrl: participant.avatarUrl,
    );

    if (result == true && mounted) {
      setState(() {
        _ratedUserIds.add(participant.userId);
      });
    }
  }

  void _onFinish() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.main,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Valorar participantes'),
        backgroundColor: AppTheme.background,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.args.exchangeTitle != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingL,
                  vertical: AppDimensions.spacingSM,
                ),
                child: Text(
                  widget.args.exchangeTitle!,
                  style: const TextStyle(
                    color: AppTheme.subtle,
                    fontSize: AppDimensions.fontSizeS,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: Text(
                '¡Intercambio confirmado! Valora a los demás participantes.',
                style: TextStyle(
                  color: AppTheme.text.withOpacity(0.9),
                  fontSize: AppDimensions.fontSizeM,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: widget.args.participants.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay participantes para valorar',
                        style: TextStyle(color: AppTheme.subtle),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingL,
                      ),
                      itemCount: widget.args.participants.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppDimensions.spacingMD),
                      itemBuilder: (context, index) {
                        final participant = widget.args.participants[index];
                        final isRated = _ratedUserIds.contains(participant.userId);

                        return _ParticipantCard(
                          participant: participant,
                          isRated: isRated,
                          onRate: () => _onRateUser(participant),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _onFinish,
                  style: FilledButton.styleFrom(
                    padding: AppDimensions.paddingButtonLarge,
                  ),
                  child: const Text('Finalizar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final RateParticipantInfo participant;
  final bool isRated;
  final VoidCallback onRate;

  const _ParticipantCard({
    required this.participant,
    required this.isRated,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.paddingCard,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.border,
            backgroundImage: participant.avatarUrl != null
                ? NetworkImage(participant.avatarUrl!)
                : null,
            child: participant.avatarUrl == null
                ? Text(
                    participant.username.isNotEmpty
                        ? participant.username[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppDimensions.spacingMD),
          Expanded(
            child: Text(
              participant.username,
              style: const TextStyle(
                color: AppTheme.text,
                fontSize: AppDimensions.fontSizeM,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isRated)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMD,
                vertical: AppDimensions.spacingSM,
              ),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    'Valorado',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: AppDimensions.fontSizeXS,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            FilledButton.tonal(
              onPressed: onRate,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingL,
                  vertical: AppDimensions.spacingSM,
                ),
              ),
              child: const Text('Valorar'),
            ),
        ],
      ),
    );
  }
}
