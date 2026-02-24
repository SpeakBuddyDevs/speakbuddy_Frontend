import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/routes.dart';
import '../theme/app_theme.dart';
import '../constants/dimensions.dart';
import '../widgets/common/app_header.dart';
import '../services/current_user_service.dart';
import '../models/generated_topic.dart';
import '../repositories/topic_repository.dart';
import '../repositories/api_topic_repository.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  final TopicRepository _repository = ApiTopicRepository();
  final CurrentUserService _userService = CurrentUserService();

  TopicCategory _selectedCategory = TopicCategory.conversation;
  String _selectedLevel = 'intermediate';
  GeneratedTopic? _currentTopic;
  bool _isLoading = false;
  bool _isSavingFavorite = false;

  @override
  void initState() {
    super.initState();
    _generateTopic();
  }

  Future<void> _generateTopic() async {
    setState(() => _isLoading = true);

    try {
      final topic = await _repository.generateTopic(
        category: _selectedCategory,
        level: _selectedLevel,
        languageCode: _userService.getNativeLanguageCode(),
      );
      if (!mounted) return;
      setState(() {
        _currentTopic = topic;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate topic: $e')),
      );
    }
  }

  void _onCategoryChanged(TopicCategory category) {
    if (category == _selectedCategory) return;
    setState(() => _selectedCategory = category);
    _generateTopic();
  }

  void _onLevelChanged(String level) {
    if (level == _selectedLevel) return;
    setState(() => _selectedLevel = level);
    _generateTopic();
  }

  Future<void> _copyToClipboard() async {
    if (_currentTopic == null) return;

    final buffer = StringBuffer();
    buffer.writeln(_currentTopic!.mainText);

    if (_currentTopic!.positionA != null) {
      buffer.writeln();
      buffer.writeln(_currentTopic!.positionA);
    }
    if (_currentTopic!.positionB != null) {
      buffer.writeln(_currentTopic!.positionB);
    }

    if (_currentTopic!.suggestedVocabulary.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Vocabulario: ${_currentTopic!.suggestedVocabulary.join(', ')}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Topic copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_currentTopic == null || _isSavingFavorite) return;

    setState(() => _isSavingFavorite = true);

    try {
      if (_currentTopic!.isFavorite && _currentTopic!.id != null) {
        await _repository.removeFromFavorites(_currentTopic!.id!);
        setState(() {
          _currentTopic = _currentTopic!.copyWith(isFavorite: false, id: null);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      } else {
        final savedTopic = await _repository.addToFavorites(_currentTopic!);
        setState(() => _currentTopic = savedTopic);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to favorites')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSavingFavorite = false);
    }
  }

  void _goToFavorites() {
    Navigator.pushNamed(context, AppRoutes.favoriteTopics);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppHeader(
        userName: _userService.getDisplayName(),
        level: _userService.getLevel(),
        levelProgress: _userService.getProgressToNextLevel(),
        isPro: _userService.isPro(),
        avatarUrl: _userService.getAvatarUrl(),
        onNotificationsTap: () {
          Navigator.pushNamed(context, AppRoutes.notifications);
        },
        onProTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pro coming soon')),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: AppDimensions.paddingScreen,
        child: Column(
          children: [
            _TopicGeneratorHeader(onFavoritesTap: _goToFavorites),
            const SizedBox(height: AppDimensions.spacingXXXL),
            _TopicCard(
              selectedCategory: _selectedCategory,
              selectedLevel: _selectedLevel,
              currentTopic: _currentTopic,
              isLoading: _isLoading,
              isSavingFavorite: _isSavingFavorite,
              onCategoryChanged: _onCategoryChanged,
              onLevelChanged: _onLevelChanged,
              onGenerateNew: _generateTopic,
              onCopy: _copyToClipboard,
              onToggleFavorite: _toggleFavorite,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicGeneratorHeader extends StatelessWidget {
  final VoidCallback onFavoritesTap;

  const _TopicGeneratorHeader({required this.onFavoritesTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: AppTheme.accent,
                size: 28,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: onFavoritesTap,
              icon: Icon(
                Icons.bookmark_outline,
                color: AppTheme.subtle,
              ),
              tooltip: 'View favorites',
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingL),
        Text(
          'AI Topic Generator',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSM),
        Text(
          'AI-generated topics for your conversations',
          style: TextStyle(
            color: AppTheme.subtle,
            fontSize: AppDimensions.fontSizeS,
          ),
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  final TopicCategory selectedCategory;
  final String selectedLevel;
  final GeneratedTopic? currentTopic;
  final bool isLoading;
  final bool isSavingFavorite;
  final void Function(TopicCategory) onCategoryChanged;
  final void Function(String) onLevelChanged;
  final VoidCallback onGenerateNew;
  final VoidCallback onCopy;
  final VoidCallback onToggleFavorite;

  const _TopicCard({
    required this.selectedCategory,
    required this.selectedLevel,
    required this.currentTopic,
    required this.isLoading,
    required this.isSavingFavorite,
    required this.onCategoryChanged,
    required this.onLevelChanged,
    required this.onGenerateNew,
    required this.onCopy,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppTheme.border),
      ),
      padding: AppDimensions.paddingCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategorySelector(
            selected: selectedCategory,
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          _LevelSelector(
            selected: selectedLevel,
            onChanged: onLevelChanged,
          ),
          const SizedBox(height: AppDimensions.spacingXXXL),
          if (isLoading)
            const _LoadingIndicator()
          else if (currentTopic != null) ...[
            _TopicContent(topic: currentTopic!),
            const SizedBox(height: AppDimensions.spacingXXXL),
            _VocabularySection(vocabulary: currentTopic!.suggestedVocabulary),
          ],
          const SizedBox(height: AppDimensions.spacingXXXL),
          _ActionButtons(
            isLoading: isLoading,
            isFavorite: currentTopic?.isFavorite ?? false,
            isSavingFavorite: isSavingFavorite,
            onGenerateNew: onGenerateNew,
            onCopy: onCopy,
            onToggleFavorite: onToggleFavorite,
          ),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final TopicCategory selected;
  final void Function(TopicCategory) onChanged;

  const _CategorySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TopicCategory.values.map((category) {
        final isSelected = category == selected;
        return Padding(
          padding: const EdgeInsets.only(right: AppDimensions.spacingSM),
          child: _SelectableChip(
            label: category.displayName.toLowerCase(),
            isSelected: isSelected,
            onTap: () => onChanged(category),
          ),
        );
      }).toList(),
    );
  }
}

class _LevelSelector extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;

  const _LevelSelector({
    required this.selected,
    required this.onChanged,
  });

  static const _levels = ['beginner', 'intermediate', 'advanced'];
  static const _levelLabels = {
    'beginner': 'beginner',
    'intermediate': 'intermediate',
    'advanced': 'advanced',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: _levels.map((level) {
        final isSelected = level == selected;
        return Padding(
          padding: const EdgeInsets.only(left: AppDimensions.spacingSM),
          child: _SelectableChip(
            label: _levelLabels[level] ?? level,
            isSelected: isSelected,
            onTap: () => onChanged(level),
            outlined: true,
          ),
        );
      }).toList(),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool outlined;

  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.outlined = false,
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
            color: isSelected
                ? (outlined ? Colors.transparent : AppTheme.accent.withValues(alpha: 0.2))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
            border: Border.all(
              color: isSelected ? AppTheme.accent : AppTheme.border,
              width: isSelected ? 1.5 : 1,
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

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spacingXXXL),
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: AppTheme.accent,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            'Generando tema...',
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeS,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXXXL),
        ],
      ),
    );
  }
}

class _TopicContent extends StatelessWidget {
  final GeneratedTopic topic;

  const _TopicContent({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          topic.mainText,
          style: TextStyle(
            color: AppTheme.text,
            fontSize: AppDimensions.fontSizeM,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        if (topic.positionA != null || topic.positionB != null) ...[
          const SizedBox(height: AppDimensions.spacingL),
          if (topic.positionA != null)
            _PositionText(text: topic.positionA!),
          if (topic.positionB != null) ...[
            const SizedBox(height: AppDimensions.spacingSM),
            _PositionText(text: topic.positionB!),
          ],
        ],
      ],
    );
  }
}

class _PositionText extends StatelessWidget {
  final String text;

  const _PositionText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppTheme.subtle,
        fontSize: AppDimensions.fontSizeS,
        height: 1.4,
      ),
    );
  }
}

class _VocabularySection extends StatelessWidget {
  final List<String> vocabulary;

  const _VocabularySection({required this.vocabulary});

  @override
  Widget build(BuildContext context) {
    if (vocabulary.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested vocabulary:',
          style: TextStyle(
            color: AppTheme.subtle,
            fontSize: AppDimensions.fontSizeS,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMD),
        Wrap(
          spacing: AppDimensions.spacingSM,
          runSpacing: AppDimensions.spacingSM,
          children: vocabulary.map((word) => _VocabularyChip(word: word)).toList(),
        ),
      ],
    );
  }
}

class _VocabularyChip extends StatelessWidget {
  final String word;

  const _VocabularyChip({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMD,
        vertical: AppDimensions.spacingSM,
      ),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        word,
        style: TextStyle(
          color: AppTheme.text,
          fontSize: AppDimensions.fontSizeS,
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isLoading;
  final bool isFavorite;
  final bool isSavingFavorite;
  final VoidCallback onGenerateNew;
  final VoidCallback onCopy;
  final VoidCallback onToggleFavorite;

  const _ActionButtons({
    required this.isLoading,
    required this.isFavorite,
    required this.isSavingFavorite,
    required this.onGenerateNew,
    required this.onCopy,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onGenerateNew,
            icon: Icon(
              Icons.auto_awesome,
              size: 18,
            ),
            label: const Text('New Topic'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.accent.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSM),
        _IconActionButton(
          icon: isFavorite ? Icons.bookmark : Icons.bookmark_outline,
          isLoading: isSavingFavorite,
          isActive: isFavorite,
          onTap: onToggleFavorite,
          tooltip: isFavorite ? 'Remove from favorites' : 'Save to favorites',
        ),
        const SizedBox(width: AppDimensions.spacingSM),
        _IconActionButton(
          icon: Icons.copy,
          onTap: onCopy,
          tooltip: 'Copy topic',
        ),
      ],
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool isLoading;
  final bool isActive;

  const _IconActionButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.isLoading = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.panel,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppTheme.border),
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.subtle,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: isActive ? AppTheme.accent : AppTheme.subtle,
                    size: AppDimensions.iconSizeM,
                  ),
          ),
        ),
      ),
    );
  }
}
