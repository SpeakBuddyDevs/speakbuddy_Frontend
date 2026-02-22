import 'dart:math';
import '../models/generated_topic.dart';
import 'topic_repository.dart';

/// Implementación fake del repositorio de topics para desarrollo
///
/// TODO(FE): Reemplazar por ApiTopicRepository cuando el backend esté listo
class FakeTopicRepository implements TopicRepository {
  static final List<GeneratedTopic> _favorites = [];
  static int _idCounter = 1;

  static final _random = Random();

  static final Map<TopicCategory, List<_TopicTemplate>> _templates = {
    TopicCategory.conversation: [
      _TopicTemplate(
        mainText: 'Cuenta una historia de tu infancia usando tiempos pasados.',
        vocabulary: ['recuerdo', 'antes', 'cuando era', 'solía', 'hace años'],
      ),
      _TopicTemplate(
        mainText: '¿Cuál es tu lugar favorito en el mundo y por qué?',
        vocabulary: ['paisaje', 'ambiente', 'experiencia', 'memorable', 'visitar'],
      ),
      _TopicTemplate(
        mainText: 'Describe tu rutina diaria ideal si no tuvieras que trabajar.',
        vocabulary: ['despertarme', 'disfrutar', 'tiempo libre', 'pasatiempo', 'relajarme'],
      ),
      _TopicTemplate(
        mainText: '¿Qué tecnología ha cambiado más tu vida en los últimos años?',
        vocabulary: ['innovación', 'dispositivo', 'conectividad', 'aplicación', 'impacto'],
      ),
      _TopicTemplate(
        mainText: 'Si pudieras cenar con cualquier persona de la historia, ¿quién sería?',
        vocabulary: ['personaje', 'histórico', 'admirar', 'preguntar', 'conversación'],
      ),
    ],
    TopicCategory.debate: [
      _TopicTemplate(
        mainText: 'El trabajo remoto es el futuro.',
        positionA: 'Postura A: El trabajo remoto aumenta la productividad y mejora la calidad de vida.',
        positionB: 'Postura B: El trabajo presencial es más efectivo para la colaboración y cultura de empresa.',
        vocabulary: ['productividad', 'flexibilidad', 'colaboración', 'balance', 'eficiencia'],
      ),
      _TopicTemplate(
        mainText: 'Las redes sociales hacen más daño que bien a la sociedad.',
        positionA: 'Postura A: Las redes sociales causan ansiedad, desinformación y adicción.',
        positionB: 'Postura B: Las redes sociales conectan personas y democratizan la información.',
        vocabulary: ['conexión', 'privacidad', 'influencia', 'comunidad', 'algoritmo'],
      ),
      _TopicTemplate(
        mainText: 'La inteligencia artificial reemplazará la mayoría de trabajos.',
        positionA: 'Postura A: La IA automatizará tareas repetitivas, liberando tiempo para trabajo creativo.',
        positionB: 'Postura B: La IA creará desempleo masivo y desigualdad económica.',
        vocabulary: ['automatización', 'creatividad', 'empleo', 'adaptación', 'innovación'],
      ),
      _TopicTemplate(
        mainText: 'El sistema educativo tradicional está obsoleto.',
        positionA: 'Postura A: Las escuelas deben modernizarse con tecnología y aprendizaje personalizado.',
        positionB: 'Postura B: La estructura tradicional proporciona disciplina y bases fundamentales.',
        vocabulary: ['aprendizaje', 'metodología', 'competencias', 'evaluación', 'currículo'],
      ),
    ],
    TopicCategory.roleplay: [
      _TopicTemplate(
        mainText: 'Uno es el entrevistador y otro el candidato buscando empleo.',
        vocabulary: ['experiencia', 'habilidades', 'puesto', 'salario', 'currículum'],
      ),
      _TopicTemplate(
        mainText: 'Estás en un restaurante. Uno es el camarero y otro el cliente con alergias alimentarias.',
        vocabulary: ['menú', 'ingredientes', 'alergia', 'recomendar', 'cuenta'],
      ),
      _TopicTemplate(
        mainText: 'Uno es el médico y otro el paciente describiendo síntomas.',
        vocabulary: ['síntomas', 'diagnóstico', 'tratamiento', 'receta', 'consulta'],
      ),
      _TopicTemplate(
        mainText: 'Estás perdido en una ciudad extranjera. Pide indicaciones a un local.',
        vocabulary: ['dirección', 'girar', 'cruzar', 'cerca', 'lejos'],
      ),
      _TopicTemplate(
        mainText: 'Uno es el recepcionista de hotel y otro un huésped con un problema en su habitación.',
        vocabulary: ['reserva', 'habitación', 'queja', 'solución', 'compensación'],
      ),
    ],
  };

  static final Map<String, List<String>> _levelAdjustments = {
    'beginner': ['básico', 'simple', 'fácil', 'común', 'frecuente'],
    'intermediate': ['moderado', 'práctico', 'útil', 'variado', 'contextual'],
    'advanced': ['complejo', 'sofisticado', 'matizado', 'técnico', 'especializado'],
  };

  @override
  Future<GeneratedTopic> generateTopic({
    required TopicCategory category,
    required String level,
    required String languageCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final templates = _templates[category] ?? _templates[TopicCategory.conversation]!;
    final template = templates[_random.nextInt(templates.length)];

    final vocabulary = List<String>.from(template.vocabulary);
    final levelWords = _levelAdjustments[level] ?? _levelAdjustments['intermediate']!;
    if (_random.nextBool()) {
      vocabulary.add(levelWords[_random.nextInt(levelWords.length)]);
    }

    return GeneratedTopic(
      category: category,
      level: level,
      mainText: template.mainText,
      positionA: template.positionA,
      positionB: template.positionB,
      suggestedVocabulary: vocabulary,
      language: languageCode,
      generatedAt: DateTime.now(),
      isFavorite: false,
    );
  }

  @override
  Future<List<GeneratedTopic>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_favorites);
  }

  @override
  Future<GeneratedTopic> addToFavorites(GeneratedTopic topic) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final savedTopic = topic.copyWith(
      id: 'fav_${_idCounter++}',
      isFavorite: true,
    );

    _favorites.add(savedTopic);
    return savedTopic;
  }

  @override
  Future<void> removeFromFavorites(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _favorites.removeWhere((t) => t.id == topicId);
  }
}

class _TopicTemplate {
  final String mainText;
  final String? positionA;
  final String? positionB;
  final List<String> vocabulary;

  const _TopicTemplate({
    required this.mainText,
    this.positionA,
    this.positionB,
    required this.vocabulary,
  });
}
