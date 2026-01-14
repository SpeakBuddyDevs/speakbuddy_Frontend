import '../models/public_exchange.dart';

/// Argumentos para la navegación a ChatScreen desde un intercambio grupal
class ExchangeChatArgs {
  /// ID del intercambio
  final String exchangeId;

  /// Datos del intercambio precargados (opcional)
  final PublicExchange? prefetchedExchange;

  const ExchangeChatArgs({
    required this.exchangeId,
    this.prefetchedExchange,
  });
}
