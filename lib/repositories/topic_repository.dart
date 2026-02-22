import '../models/generated_topic.dart';

/// Repositorio abstracto para la generación de temas con IA
///
/// BACKEND: Endpoints requeridos:
/// - POST /api/topics/generate - Generar nuevo tema
/// - GET /api/topics/favorites - Listar favoritos del usuario
/// - POST /api/topics/favorites - Guardar tema como favorito
/// - DELETE /api/topics/favorites/{id} - Eliminar de favoritos
abstract class TopicRepository {
  /// Genera un nuevo tema usando IA
  Future<GeneratedTopic> generateTopic({
    required TopicCategory category,
    required String level,
    required String languageCode,
  });

  /// Obtiene la lista de temas favoritos del usuario
  Future<List<GeneratedTopic>> getFavorites();

  /// Guarda un tema como favorito
  Future<GeneratedTopic> addToFavorites(GeneratedTopic topic);

  /// Elimina un tema de favoritos
  Future<void> removeFromFavorites(String topicId);
}
