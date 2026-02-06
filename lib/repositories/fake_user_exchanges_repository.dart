import '../models/joined_exchange.dart';
import 'user_exchanges_repository.dart';

/// Implementación fake del repositorio de intercambios del usuario (desarrollo sin backend).
/// Usar ApiUserExchangesRepository para producción.
class FakeUserExchangesRepository implements UserExchangesRepository {
  @override
  Future<List<JoinedExchange>> getJoinedExchanges() async {
    return [];
  }
}
