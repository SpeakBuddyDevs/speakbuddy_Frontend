import 'package:flutter/material.dart';

import '../constants/dimensions.dart';
import '../constants/routes.dart';
import '../models/notification_model.dart';
import '../navigation/chat_args.dart';
import '../navigation/exchange_chat_args.dart';
import '../repositories/api_notifications_repository.dart';
import '../services/current_user_service.dart';
import '../services/unread_notifications_service.dart';
import '../theme/app_theme.dart';
import '../widgets/join_request/join_request_action_bottom_sheet.dart';

/// Pantalla de notificaciones in-app
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repository = ApiNotificationsRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repository.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar notificaciones: $e')),
      );
    }
  }

  Future<void> _onNotificationTap(NotificationModel notification) async {
    // Marcar como leída
    try {
      await _repository.markAsRead(notification.id);
      UnreadNotificationsService().refresh();
    } catch (_) {}

    if (!mounted) return;

    // Solicitud de unión: mostrar bottom sheet para aceptar/rechazar
    if (notification.isJoinRequest &&
        notification.exchangeId != null &&
        notification.requesterUserId != null) {
      final exchangeTitle = _parseExchangeTitleFromBody(notification.body);
      final result = await showJoinRequestActionBottomSheet(
        context,
        exchangeId: notification.exchangeId.toString(),
        requesterUserId: notification.requesterUserId!,
        exchangeTitle: exchangeTitle,
      );
      if (result == true && mounted) {
        _loadNotifications();
        UnreadNotificationsService().refresh();
      }
      return;
    }

    // Navegar al chat correspondiente
    if (notification.isDirectMessage && notification.chatId != null) {
      // Para chat 1:1 necesitamos el otherUserId - el chatId es "chat_min_max"
      // Extraemos el otro userId (el que no soy yo - necesitaríamos AuthService)
      // Por simplicidad, navegamos al chat con el chatId. Pero ChatScreen
      // con ChatArgs espera otherUserId. El chat con ExchangeChatArgs usa exchangeId.
      // Para direct chat, el Flutter usa ChatArgs(otherUserId). El chatId incluye
      // ambos IDs. Necesitamos pasar algo que ChatScreen entienda.
      // ChatScreen con _initChat usa getOrCreateChatId(otherUserId) - ya tiene chatId
      // del stream watchMessages. El problema es que al navegar desde notificación
      // no tenemos otherUserId. La notificación tiene chatId "chat_1_2".
      // Podemos parsear chatId para obtener el "other" userId (el que no es el actual).
      // Necesitamos AuthService para obtener currentUserId.
      final otherUserId = await _parseOtherUserIdFromChatId(notification.chatId!);
      if (otherUserId != null && mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.chat,
          arguments: ChatArgs(otherUserId: otherUserId),
        ).then((_) => _loadNotifications());
      }
    } else if (notification.isExchangeMessage && notification.exchangeId != null && mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.chat,
        arguments: ExchangeChatArgs(exchangeId: notification.exchangeId.toString()),
      ).then((_) => _loadNotifications());
    } else if (notification.isJoinRequestAccepted && notification.exchangeId != null && mounted) {
      // El usuario fue aceptado: navegar al chat del intercambio
      Navigator.pushNamed(
        context,
        AppRoutes.chat,
        arguments: ExchangeChatArgs(exchangeId: notification.exchangeId.toString()),
      ).then((_) => _loadNotifications());
    }
    // isJoinRequestRejected: solo se marca como leída, no hay navegación especial
  }

  /// Extrae el título del intercambio del body "username quiere unirse a \"Título\""
  String _parseExchangeTitleFromBody(String body) {
    final match = RegExp(r'quiere unirse a "([^"]*)"').firstMatch(body);
    return match?.group(1)?.trim() ?? 'Intercambio';
  }

  /// Extrae el otherUserId del chatId "chat_min_max" (el que no es el actual)
  Future<String?> _parseOtherUserIdFromChatId(String chatId) async {
    if (!chatId.startsWith('chat_')) return null;
    final parts = chatId.substring(5).split('_');
    if (parts.length != 2) return null;
    final currentId = await CurrentUserService().getCurrentUserId();
    if (currentId == null) return parts[1];
    final id1 = parts[0];
    final id2 = parts[1];
    return currentId == id1 ? id2 : id1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notificaciones',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: AppDimensions.fontSizeL,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.spacingL),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      return _NotificationTile(
                        notification: n,
                        onTap: () => _onNotificationTap(n),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: AppTheme.subtle,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            'No tienes notificaciones',
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeM,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = notification.isDirectMessage
        ? Icons.chat_bubble_rounded
        : notification.isJoinRequest
            ? Icons.person_add_rounded
            : notification.isJoinRequestAccepted
                ? Icons.check_circle_rounded
                : notification.isJoinRequestRejected
                    ? Icons.cancel_rounded
                    : Icons.group_rounded;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
        padding: const EdgeInsets.all(AppDimensions.spacingMD),
        decoration: BoxDecoration(
          color: notification.read ? AppTheme.panel : AppTheme.card,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: notification.read ? AppTheme.border : AppTheme.accent.withValues(alpha: 0.3),
            width: notification.read ? 1 : 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingSM),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(icon, size: 24, color: AppTheme.accent),
            ),
            const SizedBox(width: AppDimensions.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: AppDimensions.fontSizeM,
                      fontWeight: notification.read ? FontWeight.w500 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    notification.body,
                    style: TextStyle(
                      color: AppTheme.subtle,
                      fontSize: AppDimensions.fontSizeS,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      color: AppTheme.subtle,
                      fontSize: AppDimensions.fontSizeXS,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
