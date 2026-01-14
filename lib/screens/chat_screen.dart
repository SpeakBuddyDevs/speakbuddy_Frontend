import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/public_user_profile.dart';
import '../navigation/chat_args.dart';
import '../repositories/fake_chat_repository.dart';
import '../constants/app_constants.dart';
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
  // BACKEND: Sustituir FakeChatRepository por ApiChatRepository
  // TODO(FE): Implementar WebSocket para watchMessages en tiempo real
  final _repository = FakeChatRepository();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  ChatArgs? _args;
  String? _chatId;
  List<ChatMessage> _messages = [];
  StreamSubscription<List<ChatMessage>>? _subscription;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_args == null) {
      _args = ModalRoute.of(context)?.settings.arguments as ChatArgs?;
      if (_args != null) {
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
    final chatId = await _repository.getOrCreateChatId(
      otherUserId: _args!.otherUserId,
    );

    if (!mounted) return;

    setState(() {
      _chatId = chatId;
    });

    _subscription = _repository.watchMessages(chatId: chatId).listen((messages) {
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
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
    final otherUser = _args?.prefetchedUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(otherUser),
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
        return MessageBubble(
          text: message.text,
          isMine: message.isMine(AppConstants.currentUserIdMock),
          createdAt: message.createdAt,
        );
      },
    );
  }
}

