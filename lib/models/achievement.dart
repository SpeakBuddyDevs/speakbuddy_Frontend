import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AchievementType {
  polyglot,
  conversationalist,
  earlyBird,
  nightOwl,
  dedicated,
  popular,
  perfectionist,
  veteran,
  star,
  streak,
  explorer,
  mentor,
  host,
  unknown,
}

class Achievement {
  final String id;
  final AchievementType type;
  final String title;
  final String description;
  final bool isUnlocked;
  final int currentProgress;
  final int targetProgress;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.isUnlocked,
    required this.currentProgress,
    required this.targetProgress,
    this.unlockedAt,
  });

  IconData get icon {
    switch (type) {
      case AchievementType.polyglot:
        return Icons.public_rounded;
      case AchievementType.conversationalist:
        return Icons.chat_bubble_rounded;
      case AchievementType.earlyBird:
        return Icons.wb_sunny_rounded;
      case AchievementType.nightOwl:
        return Icons.nightlight_round;
      case AchievementType.dedicated:
        return Icons.menu_book_rounded;
      case AchievementType.popular:
        return Icons.favorite_rounded;
      case AchievementType.perfectionist:
        return Icons.diamond_rounded;
      case AchievementType.veteran:
        return Icons.military_tech_rounded;
      case AchievementType.star:
        return Icons.star_rounded;
      case AchievementType.streak:
        return Icons.local_fire_department_rounded;
      case AchievementType.explorer:
        return Icons.explore_rounded;
      case AchievementType.mentor:
        return Icons.school_rounded;
      case AchievementType.host:
        return Icons.event_rounded;
      case AchievementType.unknown:
        return Icons.emoji_events_rounded;
    }
  }

  Color get iconColor {
    switch (type) {
      case AchievementType.polyglot:
        return AppTheme.gold;
      case AchievementType.conversationalist:
        return AppTheme.accent;
      case AchievementType.earlyBird:
        return Colors.orange;
      case AchievementType.nightOwl:
        return Colors.indigo;
      case AchievementType.dedicated:
        return Colors.brown;
      case AchievementType.popular:
        return Colors.pink;
      case AchievementType.perfectionist:
        return Colors.cyan;
      case AchievementType.veteran:
        return AppTheme.gold;
      case AchievementType.star:
        return AppTheme.gold;
      case AchievementType.streak:
        return Colors.deepOrange;
      case AchievementType.explorer:
        return Colors.teal;
      case AchievementType.mentor:
        return Colors.purple;
      case AchievementType.host:
        return Colors.green;
      case AchievementType.unknown:
        return AppTheme.subtle;
    }
  }

  double get progressPercent {
    if (targetProgress == 0) return 0;
    return (currentProgress / targetProgress).clamp(0.0, 1.0);
  }

  int get progressPercentInt => (progressPercent * 100).round();

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id']?.toString() ?? '',
      type: _parseType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      currentProgress: json['currentProgress'] as int? ?? 0,
      targetProgress: json['targetProgress'] as int? ?? 1,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'] as String)
          : null,
    );
  }

  static AchievementType _parseType(String? typeStr) {
    if (typeStr == null) return AchievementType.unknown;
    
    switch (typeStr.toUpperCase()) {
      case 'POLYGLOT':
        return AchievementType.polyglot;
      case 'CONVERSATIONALIST':
        return AchievementType.conversationalist;
      case 'EARLY_BIRD':
        return AchievementType.earlyBird;
      case 'NIGHT_OWL':
        return AchievementType.nightOwl;
      case 'DEDICATED':
        return AchievementType.dedicated;
      case 'POPULAR':
        return AchievementType.popular;
      case 'PERFECTIONIST':
        return AchievementType.perfectionist;
      case 'VETERAN':
        return AchievementType.veteran;
      case 'STAR':
        return AchievementType.star;
      case 'STREAK':
        return AchievementType.streak;
      case 'EXPLORER':
        return AchievementType.explorer;
      case 'MENTOR':
        return AchievementType.mentor;
      case 'HOST':
        return AchievementType.host;
      default:
        return AchievementType.unknown;
    }
  }

  Achievement copyWith({
    String? id,
    AchievementType? type,
    String? title,
    String? description,
    bool? isUnlocked,
    int? currentProgress,
    int? targetProgress,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
