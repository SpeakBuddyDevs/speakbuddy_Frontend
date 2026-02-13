import 'package:flutter/material.dart';
import '../models/joined_exchange.dart';
import '../theme/app_theme.dart';
import '../constants/dimensions.dart';
import '../constants/routes.dart';
import '../navigation/exchange_chat_args.dart';
import '../widgets/exchange/joined_exchange_card.dart';

/// Pantalla que muestra el historial de intercambios completados.
/// Se accede desde el icono de calendario en la pantalla principal.
class ExchangeHistoryScreen extends StatelessWidget {
  const ExchangeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final raw = args is List<JoinedExchange> ? args : <JoinedExchange>[];
    final completedExchanges = List<JoinedExchange>.from(raw)
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          color: AppTheme.text,
        ),
        title: Text(
          'Historial de intercambios',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: AppDimensions.fontSizeL,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: completedExchanges.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingXXXL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 64,
                      color: AppTheme.subtle,
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                    Text(
                      'No hay intercambios completados',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.subtle,
                        fontSize: AppDimensions.fontSizeM,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: AppDimensions.paddingScreen,
              itemCount: completedExchanges.length,
              itemBuilder: (context, index) {
                final exchange = completedExchanges[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
                  child: JoinedExchangeCard(
                    exchange: exchange,
                    onOpenChat: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.chat,
                        arguments: ExchangeChatArgs(exchangeId: exchange.id),
                      );
                    },
                    hasNewMessages: false,
                  ),
                );
              },
            ),
    );
  }
}
