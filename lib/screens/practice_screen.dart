import 'package:flutter/material.dart';

import '../data/app_content.dart';
import '../models/app_models.dart';
import '../services/progress_service.dart';
import '../services/sfx_service.dart';
import '../services/tts_service.dart';
import '../widgets/kiddo_widgets.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    required this.progress,
    required this.tts,
  });

  final ProgressService progress;
  final TtsService tts;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  LearningCategory _category = LearningCategory.letters;
  String? _selectedId;
  String _selectedLabel = 'Tap a card: A for Apple, B for Ball...';

  @override
  Widget build(BuildContext context) {
    final items = AppContent.learningItems
        .where((item) => item.category == _category)
        .toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760
            ? 5
            : constraints.maxWidth > 520
                ? 4
                : 2;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PracticeHeader(
                    selectedLabel: _selectedLabel,
                    tts: widget.tts,
                  ),
                  const SizedBox(height: 18),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: LearningCategory.values.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category.label),
                            selected: _category == category,
                            onSelected: (_) {
                              SfxService.tap();
                              setState(() {
                                _category = category;
                                _selectedId = null;
                                _selectedLabel = category ==
                                        LearningCategory.letters
                                    ? 'Tap a card: A for Apple, B for Ball...'
                                    : category == LearningCategory.numbers
                                        ? 'Tap a number: 1 for One Piece...'
                                        : 'Pick a ${category.label.toLowerCase()} card.';
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return LearningTile(
                        item: item,
                        selected: _selectedId == item.id,
                        onTap: () {
                          widget.tts.speak(item.spokenText);
                          setState(() {
                            _selectedId = item.id;
                            _selectedLabel = item.subtitle;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PracticeHeader extends StatelessWidget {
  const _PracticeHeader({
    required this.selectedLabel,
    required this.tts,
  });

  final String selectedLabel;
  final TtsService tts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C2A8), Color(0xFF4D96FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Practice Room',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  selectedLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          VoiceButton(
            enabled: tts.enabled,
            onPressed: () => tts.speak(
              'Practice room. Tap a card like A for Apple or 1 for One Piece.',
            ),
          ),
        ],
      ),
    );
  }
}
