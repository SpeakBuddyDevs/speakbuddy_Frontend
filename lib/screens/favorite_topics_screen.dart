import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../constants/dimensions.dart';
import '../models/generated_topic.dart';
import '../repositories/topic_repository.dart';
import '../repositories/api_topic_repository.dart';

class FavoriteTopicsScreen extends StatefulWidget {
  const FavoriteTopicsScreen({super.key});

  @override
  State<FavoriteTopicsScreen> createState() => _FavoriteTopicsScreenState();
}

class _FavoriteTopicsScreenState extends State<FavoriteTopicsScreen> {
  final TopicRepository _repository = ApiTopicRepository();

  List<GeneratedTopic>? _favorites;
  bool _isLoading = true;
  TopicCategory? _filterCategory;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final favorites = await _repository.getFavorites();
      if (!mounted) return;
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _favorites = [];
        _isLoading = false;
      });
    }
  }

  List<GeneratedTopic> get _filteredFavorites {
    if (_favorites == null) return [];
    if (_filterCategory == null) return _favorites!;
    return _favorites!.where((t) => t.category == _filterCategory).toList();
  }

  Future<void> _removeFavorite(GeneratedTopic topic) async {
    if (topic.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('Eliminar favorito'),
        content: const Text('¿Quieres eliminar este tema de tus favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _repository.removeFromFavorites(topic.id!);
      if (!mounted) return;
      setState(() {
        _favorites?.removeWhere((t) => t.id == topic.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eliminado de favoritos')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _copyTopic(GeneratedTopic topic) async {
    final buffer = StringBuffer();
    buffer.writeln(topic.mainText);

    if (topic.positionA != null) {
      buffer.writeln();
      buffer.writeln(topic.positionA);
    }
    if (topic.positionB != null) {
      buffer.writeln(topic.positionB);
    }

    if (topic.suggestedVocabulary.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Vocabulario: ${topic.suggestedVocabulary.join(', ')}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tema copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text('Temas Favoritos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _FilterBar(
            selectedCategory: _filterCategory,
            onCategoryChanged: (category) {
              setState(() => _filterCategory = category);
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFavorites.isEmpty
                    ? _EmptyState(hasFilter: _filterCategory != null)
                    : RefreshIndicator(
                        onRefresh: _loadFavorites,
                        color: AppTheme.accent,
                        child: ListView.builder(
                          padding: AppDimensions.paddingScreen,
                          itemCount: _filteredFavorites.length,
                          itemBuilder: (context, index) {
                            final topic = _filteredFavorites[index];
                            return _FavoriteTopicCard(
                              topic: topic,
                              onCopy: () => _copyTopic(topic),
                              onRemove: () => _removeFavorite(topic),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final TopicCategory? selectedCategory;
  final void Function(TopicCategory?) onCategoryChanged;

  const _FilterBar({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingL,
        vertical: AppDimensions.spacingMD,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Todos',
              isSelected: selectedCategory == null,
              onTap: () => onCategoryChanged(null),
            ),
            const SizedBox(width: AppDimensions.spacingSM),
            ...TopicCategory.values.map((category) => Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.spacingSM),
                  child: _FilterChip(
                    label: category.displayName,
                    isSelected: selectedCategory == category,
                    onTap: () => onCategoryChanged(category),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMD,
            vertical: AppDimensions.spacingSM,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accent.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
            border: Border.all(
              color: isSelected ? AppTheme.accent : AppTheme.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.accent : AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;

  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline,
            size: 64,
            color: AppTheme.subtle,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            hasFilter
                ? 'No hay favoritos en esta categoría'
                : 'No tienes temas favoritos',
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeM,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            hasFilter
                ? 'Prueba con otra categoría'
                : 'Guarda temas desde el generador',
            style: TextStyle(
              color: AppTheme.subtle.withValues(alpha: 0.7),
              fontSize: AppDimensions.fontSizeS,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteTopicCard extends StatelessWidget {
  final GeneratedTopic topic;
  final VoidCallback onCopy;
  final VoidCallback onRemove;

  const _FavoriteTopicCard({
    required this.topic,
    required this.onCopy,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppDimensions.paddingCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CategoryBadge(category: topic.category),
                    const SizedBox(width: AppDimensions.spacingSM),
                    _LevelBadge(level: topic.level),
                    const Spacer(),
                    Text(
                      _formatDate(topic.generatedAt),
                      style: TextStyle(
                        color: AppTheme.subtle,
                        fontSize: AppDimensions.fontSizeXS,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMD),
                Text(
                  topic.mainText,
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                if (topic.positionA != null || topic.positionB != null) ...[
                  const SizedBox(height: AppDimensions.spacingMD),
                  if (topic.positionA != null)
                    Text(
                      topic.positionA!,
                      style: TextStyle(
                        color: AppTheme.subtle,
                        fontSize: AppDimensions.fontSizeS,
                      ),
                    ),
                  if (topic.positionB != null) ...[
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      topic.positionB!,
                      style: TextStyle(
                        color: AppTheme.subtle,
                        fontSize: AppDimensions.fontSizeS,
                      ),
                    ),
                  ],
                ],
                if (topic.suggestedVocabulary.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingMD),
                  Wrap(
                    spacing: AppDimensions.spacingXS,
                    runSpacing: AppDimensions.spacingXS,
                    children: topic.suggestedVocabulary
                        .take(5)
                        .map((word) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingSM,
                                vertical: AppDimensions.spacingXS,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.panel,
                                borderRadius:
                                    BorderRadius.circular(AppDimensions.radiusS),
                              ),
                              child: Text(
                                word,
                                style: TextStyle(
                                  color: AppTheme.subtle,
                                  fontSize: AppDimensions.fontSizeXS,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.copy,
                    label: 'Copiar',
                    onTap: onCopy,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.border,
                ),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.delete_outline,
                    label: 'Eliminar',
                    onTap: onRemove,
                    isDestructive: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoy';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final TopicCategory category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        category.displayName,
        style: TextStyle(
          color: AppTheme.accent,
          fontSize: AppDimensions.fontSizeXS,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: AppTheme.subtle,
          fontSize: AppDimensions.fontSizeXS,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : AppTheme.subtle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMD),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppDimensions.spacingSM),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: AppDimensions.fontSizeS,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
