import 'package:flutter/material.dart';

enum LearningCategory { letters, numbers, colors, shapes, words, planets }

extension LearningCategoryLabel on LearningCategory {
  String get label {
    switch (this) {
      case LearningCategory.letters:
        return 'Letters';
      case LearningCategory.numbers:
        return 'Numbers';
      case LearningCategory.colors:
        return 'Colors';
      case LearningCategory.shapes:
        return 'Shapes';
      case LearningCategory.words:
        return 'Words';
      case LearningCategory.planets:
        return 'Planets';
    }
  }
}

class LearningItem {
  const LearningItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.spokenText,
    required this.category,
    required this.color,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final String spokenText;
  final LearningCategory category;
  final Color color;
  final IconData icon;
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.spokenPrompt,
    required this.options,
    required this.answer,
    required this.hint,
    required this.category,
  });

  final String id;
  final String prompt;
  final String spokenPrompt;
  final List<String> options;
  final String answer;
  final String hint;
  final LearningCategory category;
}

class GameLevel {
  const GameLevel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.assetPath,
    required this.color,
    required this.requiredStars,
    required this.rewardStars,
    required this.questionIds,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String assetPath;
  final Color color;
  final int requiredStars;
  final int rewardStars;
  final List<String> questionIds;
}

class BadgeItem {
  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.assetPath,
    required this.color,
    required this.requiredStars,
  });

  final String id;
  final String title;
  final String description;
  final String assetPath;
  final Color color;
  final int requiredStars;
}

class AppProgress {
  const AppProgress({
    required this.totalStars,
    required this.bestScore,
    required this.completedLevelIds,
    required this.levelStars,
    required this.unlockedBadgeIds,
    required this.ttsEnabled,
    required this.sfxEnabled,
  });

  factory AppProgress.initial() => const AppProgress(
        totalStars: 0,
        bestScore: 0,
        completedLevelIds: <String>{},
        levelStars: <String, int>{},
        unlockedBadgeIds: <String>{},
        ttsEnabled: true,
        sfxEnabled: true,
      );

  final int totalStars;
  final int bestScore;
  final Set<String> completedLevelIds;
  final Map<String, int> levelStars;
  final Set<String> unlockedBadgeIds;
  final bool ttsEnabled;
  final bool sfxEnabled;

  AppProgress copyWith({
    int? totalStars,
    int? bestScore,
    Set<String>? completedLevelIds,
    Map<String, int>? levelStars,
    Set<String>? unlockedBadgeIds,
    bool? ttsEnabled,
    bool? sfxEnabled,
  }) {
    return AppProgress(
      totalStars: totalStars ?? this.totalStars,
      bestScore: bestScore ?? this.bestScore,
      completedLevelIds: completedLevelIds ?? this.completedLevelIds,
      levelStars: levelStars ?? this.levelStars,
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
    );
  }
}
