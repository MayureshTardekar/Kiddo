import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_content.dart';
import '../models/app_models.dart';

class ProgressService extends ChangeNotifier {
  static const _starsKey = 'totalStars';
  static const _bestScoreKey = 'bestScore';
  static const _completedKey = 'completedLevels';
  static const _levelStarsKey = 'levelStars';
  static const _badgesKey = 'badges';
  static const _ttsKey = 'ttsEnabled';
  static const _sfxKey = 'sfxEnabled';

  SharedPreferences? _prefs;
  AppProgress _progress = AppProgress.initial();
  bool _loaded = false;

  AppProgress get progress => _progress;
  bool get loaded => _loaded;
  int get totalStars => _progress.totalStars;
  int get bestScore => _progress.bestScore;
  bool get ttsEnabled => _progress.ttsEnabled;
  bool get sfxEnabled => _progress.sfxEnabled;

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final levelStarEntries = _prefs!.getStringList(_levelStarsKey) ?? [];
      _progress = AppProgress(
        totalStars: _prefs!.getInt(_starsKey) ?? 0,
        bestScore: _prefs!.getInt(_bestScoreKey) ?? 0,
        completedLevelIds: (_prefs!.getStringList(_completedKey) ?? []).toSet(),
        levelStars: _parseLevelStars(levelStarEntries),
        unlockedBadgeIds: (_prefs!.getStringList(_badgesKey) ?? []).toSet(),
        ttsEnabled: _prefs!.getBool(_ttsKey) ?? true,
        sfxEnabled: _prefs!.getBool(_sfxKey) ?? true,
      );
      _syncBadges();
    } catch (error) {
      debugPrint('Progress storage unavailable, using memory only: $error');
    }
    _loaded = true;
    notifyListeners();
  }

  bool isLevelUnlocked(GameLevel level) {
    return level.requiredStars <= _progress.totalStars;
  }

  int starsForLevel(String levelId) {
    return _progress.levelStars[levelId] ?? 0;
  }

  bool isBadgeUnlocked(BadgeItem badge) {
    return _progress.unlockedBadgeIds.contains(badge.id) ||
        _progress.totalStars >= badge.requiredStars;
  }

  Future<void> completeLevel({
    required GameLevel level,
    required int score,
    required int starRating,
  }) async {
    final safeRating = starRating.clamp(1, 3);
    final previousRating = starsForLevel(level.id);
    final bonusStars = level.rewardStars + (safeRating * 2);
    final levelStars = Map<String, int>.from(_progress.levelStars);
    levelStars[level.id] =
        safeRating > previousRating ? safeRating : previousRating;

    _progress = _progress.copyWith(
      totalStars: _progress.totalStars + bonusStars,
      bestScore: score > _progress.bestScore ? score : _progress.bestScore,
      completedLevelIds: {..._progress.completedLevelIds, level.id},
      levelStars: levelStars,
    );
    _syncBadges();
    notifyListeners();
    await _save();
  }

  Future<void> awardBonusStars(int stars) async {
    _progress = _progress.copyWith(totalStars: _progress.totalStars + stars);
    _syncBadges();
    notifyListeners();
    await _save();
  }

  Future<void> setTtsEnabled(bool value) async {
    _progress = _progress.copyWith(ttsEnabled: value);
    notifyListeners();
    await _save();
  }

  Future<void> setSfxEnabled(bool value) async {
    _progress = _progress.copyWith(sfxEnabled: value);
    notifyListeners();
    await _save();
  }

  Future<void> reset() async {
    _progress = AppProgress.initial();
    notifyListeners();
    await _save();
  }

  void _syncBadges() {
    final unlocked = {
      ..._progress.unlockedBadgeIds,
      ...AppContent.badges
          .where((badge) => _progress.totalStars >= badge.requiredStars)
          .map((badge) => badge.id),
    };
    _progress = _progress.copyWith(unlockedBadgeIds: unlocked);
  }

  Future<void> _save() async {
    final prefs = _prefs;
    if (prefs == null) return;
    try {
      await prefs.setInt(_starsKey, _progress.totalStars);
      await prefs.setInt(_bestScoreKey, _progress.bestScore);
      await prefs.setStringList(
        _completedKey,
        _progress.completedLevelIds.toList()..sort(),
      );
      await prefs.setStringList(
        _levelStarsKey,
        _progress.levelStars.entries
            .map((entry) => '${entry.key}:${entry.value}')
            .toList(),
      );
      await prefs.setStringList(
        _badgesKey,
        _progress.unlockedBadgeIds.toList()..sort(),
      );
      await prefs.setBool(_ttsKey, _progress.ttsEnabled);
      await prefs.setBool(_sfxKey, _progress.sfxEnabled);
    } catch (error) {
      debugPrint('Progress save skipped: $error');
    }
  }

  Map<String, int> _parseLevelStars(List<String> entries) {
    final map = <String, int>{};
    for (final entry in entries) {
      final parts = entry.split(':');
      if (parts.length != 2) continue;
      map[parts.first] = int.tryParse(parts.last) ?? 0;
    }
    return map;
  }
}
