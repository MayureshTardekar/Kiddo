import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../data/app_content.dart';
import '../models/app_models.dart';
import '../services/progress_service.dart';
import '../services/sfx_service.dart';
import '../services/tts_service.dart';
import '../widgets/kiddo_widgets.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.progress,
    required this.tts,
  });

  final ProgressService progress;
  final TtsService tts;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late GameLevel _level;
  late List<QuizQuestion> _questions;
  late ConfettiController _confetti;
  int _questionCount = 3;
  int _index = 0;
  int _score = 0;
  int _correct = 0;
  bool _locked = false;
  String _feedback = 'Choose an unlocked level and answer the question.';

  QuizQuestion get _question => _questions[_index];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 900));
    _startLevel(AppContent.levels.first, speak: false);
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _changeQuestionCount(int count) {
    if (_questionCount == count) return;
    SfxService.tap();
    setState(() => _questionCount = count);
    _startLevel(_level, speak: false);
    widget.tts.speak('$count question quiz selected.');
  }

  void _startLevel(GameLevel level, {bool speak = true}) {
    if (!widget.progress.isLevelUnlocked(level)) {
      SfxService.error();
      setState(
        () => _feedback =
            'Collect ${level.requiredStars} stars to unlock ${level.title}.',
      );
      return;
    }

    final questions = AppContent.questionsForLevel(level).toList();
    questions.shuffle(Random(DateTime.now().millisecondsSinceEpoch));

    setState(() {
      _level = level;
      _questions = questions.take(_questionCount).toList(growable: false);
      _index = 0;
      _score = 0;
      _correct = 0;
      _locked = false;
      _feedback = '${level.description} $_questionCount questions selected.';
    });
    if (speak) widget.tts.speak(_feedback);
  }

  Future<void> _answer(String option) async {
    if (_locked) return;
    setState(() => _locked = true);
    final correct = option == _question.answer;
    if (correct) {
      SfxService.success();
      _confetti.play();
      setState(() {
        _score += 10;
        _correct += 1;
        _feedback = 'Correct. Super work!';
      });
      widget.tts.speak('Correct. Super work!');
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      if (_index == _questions.length - 1) {
        await _finishLevel();
      } else {
        setState(() {
          _index += 1;
          _locked = false;
          _feedback = 'Next question. You can do it.';
        });
      }
    } else {
      SfxService.error();
      setState(() {
        _locked = false;
        _feedback = 'Try again. Hint: ${_question.hint}';
      });
      widget.tts.speak('Try again. ${_question.hint}');
    }
  }

  Future<void> _finishLevel() async {
    final ratio = _correct / _questions.length;
    final rating = ratio >= 0.95
        ? 3
        : ratio >= 0.65
            ? 2
            : 1;
    await widget.progress.completeLevel(
      level: _level,
      score: _score,
      starRating: rating,
    );
    if (!mounted) return;
    setState(() {
      _locked = false;
      _feedback =
          'Level complete. You earned ${_level.rewardStars + (rating * 2)} stars.';
    });
    widget.tts.speak(_feedback);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Level Complete', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/badges/trophy_star.png',
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFFFCA3A),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Score $_score',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Icon(
                  index < rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: const Color(0xFFFFCA3A),
                  size: 34,
                ),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    _startLevel(_level, speak: false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 780;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quiz Quest',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  _feedback,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StarPill(stars: widget.progress.totalStars),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _QuestionCountSelector(
                        selectedCount: _questionCount,
                        onSelected: _changeQuestionCount,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 190,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final level = AppContent.levels[index];
                            return LevelCard(
                              level: level,
                              unlocked: widget.progress.isLevelUnlocked(level),
                              rating: widget.progress.starsForLevel(level.id),
                              onTap: () {
                                SfxService.tap();
                                _startLevel(level);
                              },
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemCount: AppContent.levels.length,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: _level.color.withOpacity(0.25),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _level.color.withOpacity(0.14),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Flex(
                          direction: wide ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: wide ? 6 : 0,
                              child: Column(
                                crossAxisAlignment: wide
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: wide
                                        ? MainAxisAlignment.start
                                        : MainAxisAlignment.center,
                                    children: [
                                      VoiceButton(
                                        enabled: widget.tts.enabled,
                                        onPressed: () => widget.tts
                                            .speak(_question.spokenPrompt),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Question ${_index + 1}/${_questions.length}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    _question.prompt,
                                    textAlign: wide
                                        ? TextAlign.left
                                        : TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Score $_score',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF6C63FF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: wide ? 18 : 0,
                              height: wide ? 0 : 18,
                            ),
                            Expanded(
                              flex: wide ? 5 : 0,
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: _question.options
                                    .map(
                                      (option) => AnswerButton(
                                        option: option,
                                        isCorrect: option == _question.answer,
                                        enabled: !_locked,
                                        onTap: () => _answer(option),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 18,
            gravity: 0.4,
          ),
        ),
      ],
    );
  }
}

class _QuestionCountSelector extends StatelessWidget {
  const _QuestionCountSelector({
    required this.selectedCount,
    required this.onSelected,
  });

  final int selectedCount;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6E9FF), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.quiz_rounded, color: Color(0xFF6C63FF)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Questions',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 3, label: Text('3')),
              ButtonSegment(value: 5, label: Text('5')),
              ButtonSegment(value: 10, label: Text('10')),
            ],
            selected: {selectedCount},
            onSelectionChanged: (selection) => onSelected(selection.first),
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStateProperty.all(
                const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
