import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/public_user_profile.dart';
import '../navigation/chat_args.dart';
import '../navigation/exchange_chat_args.dart';
import '../navigation/public_profile_args.dart';
import '../models/public_exchange.dart';
import '../repositories/api_chat_repository.dart';
import '../repositories/api_users_repository.dart';
import '../repositories/fake_exchange_participants_repository.dart';
import '../services/current_user_service.dart';
import '../services/exchange_chat_read_service.dart';
import '../constants/app_constants.dart';
import '../constants/routes.dart';
import '../theme/app_theme.dart';
import '../constants/dimensions.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/chat_input.dart';

/// Pantalla de chat con un usuario
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _repository = ApiChatRepository();
  final _usersRepository = ApiUsersRepository();
  // BACKEND: Sustituir FakeExchangeParticipantsRepository por ApiExchangeParticipantsRepository
  final _participantsRepository = FakeExchangeParticipantsRepository();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  dynamic _args; // Puede ser ChatArgs o ExchangeChatArgs
  String? _chatId;
  List<ChatMessage> _messages = [];
  StreamSubscription<List<ChatMessage>>? _subscription;
  bool _isLoading = true;
  bool _isExchangeChat = false;
  PublicExchange? _exchange;
  Map<String, String> _senderNames = {}; // Mapa senderId -> nombre para chats grupales
  List<PublicUserProfile> _participants = [];
  String? _currentUserId; // ID real del usuario (para isMine en chat de intercambio)
  /// Perfil del otro usuario cargado cuando se entra desde notificaciones (sin prefetchedUser)
  PublicUserProfile? _loadedOtherUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args == null) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      
      // Intentar como ExchangeChatArgs primero
      if (routeArgs is ExchangeChatArgs) {
        _args = routeArgs;
        _isExchangeChat = true;
        _exchange = routeArgs.prefetchedExchange;
        _initExchangeChat();
      } 
      // Si no, intentar como ChatArgs
      else if (routeArgs is ChatArgs) {
        _args = routeArgs;
        _isExchangeChat = false;
        _initChat();
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _initChat() async {
    final chatArgs = _args as ChatArgs;
    final chatId = await _repository.getOrCreateChatId(
      otherUserId: chatArgs.otherUserId,
    );

    if (!mounted) return;

    final currentUserId = await CurrentUserService().getCurrentUserId();
    if (!mounted) return;

    setState(() {
      _chatId = chatId;
      _currentUserId = currentUserId;
    });

    // Si no tenemos perfil precargado (p. ej. entrada desde notificaciones), cargarlo
    if (chatArgs.prefetchedUser == null) {
      try {
        final profile = await _usersRepository.getPublicProfile(chatArgs.otherUserId);
        if (!mounted) return;
        setState(() => _loadedOtherUser = profile);
      } catch (_) {
        // Mantener _loadedOtherUser null; la cabecera mostrará "Usuario"
      }
    }

    _subscription = _repository.watchMessages(chatId: chatId).listen((messages) {
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }

  Future<void> _initExchangeChat() async {
    final exchangeArgs = _args as ExchangeChatArgs;
    final chatId = await _repository.getOrCreateExchangeChatId(
      exchangeId: exchangeArgs.exchangeId,
    );

    if (!mounted) return;

    setState(() {
      _chatId = chatId;
    });

    // Cargar participantes del intercambio
    // BACKEND: GET /api/exchanges/{exchangeId}/participants
    // Response: { "participants": [{ id, name, avatarUrl?, ... }] }
    final participants = await _participantsRepository.getParticipants(exchangeArgs.exchangeId);
    
    // Crear mapa de senderId -> nombre
    final senderNamesMap = <String, String>{};
    for (final participant in participants) {
      senderNamesMap[participant.id] = participant.name;
    }
    // Añadir nombre para mensajes del sistema
    senderNamesMap['system_bot'] = 'Sistema';

    if (!mounted) return;

    final currentUserId = await CurrentUserService().getCurrentUserId();

    if (!mounted) return;

    setState(() {
      _participants = participants;
      _senderNames = senderNamesMap;
      _currentUserId = currentUserId;
    });

    _subscription = _repository.watchMessages(chatId: chatId).listen((messages) {
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
      // Marcar como vistos hasta el último mensaje (para ocultar "Nuevos" en Home)
      if (messages.isNotEmpty) {
        final last = messages.last;
        ExchangeChatReadService().setLastSeenAt(exchangeArgs.exchangeId, last.createdAt);
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_chatId == null) return;
    
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    await _repository.sendMessage(chatId: _chatId!, text: text);
  }

  @override
  Widget build(BuildContext context) {
    final prefetched = _isExchangeChat ? null : (_args as ChatArgs?)?.prefetchedUser;
    final otherUser = prefetched ?? _loadedOtherUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _isExchangeChat ? _buildExchangeAppBar() : _buildAppBar(otherUser),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(),
          ),
          ChatInput(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(PublicUserProfile? user) {
    return AppBar(
      backgroundColor: AppTheme.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppTheme.text),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.panel,
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null
                    ? Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (user?.isOnline == true)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.background, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppDimensions.spacingMD),
          // Nombre y estado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Usuario',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (user?.isOnline == true)
                  Text(
                    'En línea',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: AppDimensions.fontSizeXS,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: AppTheme.subtle,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            'Inicia la conversación',
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeM,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        // Nombre: del mensaje (API) o del mapa de participantes (chat de intercambio)
        final senderName = message.senderName ?? (_isExchangeChat ? _senderNames[message.senderId] : null);
        return MessageBubble(
          text: message.text,
          isMine: message.isMine(_currentUserId ?? AppConstants.currentUserIdMock),
          createdAt: message.createdAt,
          senderName: senderName,
        );
      },
    );
  }

  PreferredSizeWidget _buildExchangeAppBar() {
    final exchange = _exchange;
    final title = exchange?.title ?? 'Chat del intercambio';
    final languages = exchange != null
        ? '${exchange.nativeLanguage} → ${exchange.targetLanguage}'
        : '';

    return AppBar(
      backgroundColor: AppTheme.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppTheme.text),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.text,
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (languages.isNotEmpty)
            Text(
              languages,
              style: TextStyle(
                color: AppTheme.subtle,
                fontSize: AppDimensions.fontSizeXS,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.group_rounded,
            color: AppTheme.subtle,
            size: AppDimensions.iconSizeM,
          ),
          onPressed: _showParticipantsBottomSheet,
          tooltip: 'Ver participantes',
        ),
        const SizedBox(width: AppDimensions.spacingSM),
      ],
    );
  }

  void _showParticipantsBottomSheet() {
    if (!_isExchangeChat || _participants.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
      ),
      builder: (context) => _ParticipantsBottomSheet(
        participants: _participants,
        onParticipantTap: (participant) {
          Navigator.pop(context); // Cerrar bottom sheet
          Navigator.pushNamed(
            context,
            AppRoutes.publicProfile,
            arguments: PublicProfileArgs(
              userId: participant.id,
              prefetched: participant,
            ),
          );
        },
      ),
    );
  }
}

/// Bottom sheet para mostrar la lista de participantes del intercambio
class _ParticipantsBottomSheet extends StatelessWidget {
  final List<PublicUserProfile> participants;
  final Function(PublicUserProfile) onParticipantTap;

  const _ParticipantsBottomSheet({
    required this.participants,
    required this.onParticipantTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.paddingBottomSheet,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Título
          Text(
            'Participantes (${participants.length})',
            style: TextStyle(
              color: AppTheme.text,
              fontSize: AppDimensions.fontSizeL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          // Lista de participantes
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];
                return _ParticipantTile(
                  participant: participant,
                  onTap: () => onParticipantTap(participant),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile individual de participante
class _ParticipantTile extends StatelessWidget {
  final PublicUserProfile participant;
  final VoidCallback onTap;

  const _ParticipantTile({
    required this.participant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingMD,
          horizontal: AppDimensions.spacingSM,
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.panel,
                  backgroundImage: participant.avatarUrl != null
                      ? NetworkImage(participant.avatarUrl!)
                      : null,
                  child: participant.avatarUrl == null
                      ? Text(
                          participant.name.isNotEmpty
                              ? participant.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: AppTheme.text,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (participant.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          participant.name,
                          style: TextStyle(
                            color: AppTheme.text,
                            fontSize: AppDimensions.fontSizeM,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (participant.isPro) ...[
                        const SizedBox(width: AppDimensions.spacingXS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingSM,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'PRO',
                            style: TextStyle(
                              color: AppTheme.gold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppTheme.subtle,
                      ),
                      const SizedBox(width: AppDimensions.spacingXS),
                      Text(
                        participant.country,
                        style: TextStyle(
                          color: AppTheme.subtle,
                          fontSize: AppDimensions.fontSizeXS,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Rating
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppTheme.gold,
                  size: AppDimensions.iconSizeS,
                ),
                const SizedBox(width: AppDimensions.spacingXS),
                Text(
                  participant.rating.toStringAsFixed(1),
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: AppDimensions.fontSizeS,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppDimensions.spacingSM),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.subtle,
              size: AppDimensions.iconSizeM,
            ),
          ],
        ),
      ),
    );
  }
}

