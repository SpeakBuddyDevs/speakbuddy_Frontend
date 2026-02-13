import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Burbuja de mensaje para el chat
class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMine;
  final DateTime createdAt;
  final String? senderName; // Nombre del remitente (solo para chats grupales)

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMine,
    required this.createdAt,
    this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isMine ? 50 : 0,
          right: isMine ? 0 : 50,
          bottom: AppDimensions.spacingSM,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingMD,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppTheme.accent : AppTheme.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppDimensions.radiusL),
            topRight: const Radius.circular(AppDimensions.radiusL),
            bottomLeft: Radius.circular(isMine ? AppDimensions.radiusL : AppDimensions.radiusXS),
            bottomRight: Radius.circular(isMine ? AppDimensions.radiusXS : AppDimensions.radiusL),
          ),
          border: isMine ? null : Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del remitente: "Tú" para mis mensajes, nombre para el resto
            Text(
              isMine ? 'Tú' : (senderName ?? 'Usuario'),
              style: TextStyle(
                color: isMine ? Colors.white70 : AppTheme.subtle,
                fontSize: AppDimensions.fontSizeXS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            Text(
              text,
              style: TextStyle(
                color: isMine ? Colors.white : AppTheme.text,
                fontSize: AppDimensions.fontSizeM,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _formatTime(createdAt),
                style: TextStyle(
                  color: isMine ? Colors.white70 : AppTheme.subtle,
                  fontSize: AppDimensions.fontSizeXS,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

