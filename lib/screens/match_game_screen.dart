import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_content.dart';
import '../models/app_models.dart';
import '../services/progress_service.dart';
import '../services/sfx_service.dart';
import '../services/tts_service.dart';

class MatchGameScreen extends StatefulWidget {
  const MatchGameScreen({
    super.key,
    required this.progress,
    required this.tts,
  });

  final ProgressService progress;
  final TtsService tts;

  @override
  State<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends State<MatchGameScreen> {
  late List<LearningItem> _items;
  late LearningItem _target;
  int _round = 1;
  String _message = 'Drag the matching tile into the glowing portal.';

  @override
  void initState() {
    super.initState();
    _items = AppContent.matchItems();
    _pickTarget();
  }

  void _pickTarget() {
    _target = _items[Random().nextInt(_items.length)];
  }

  Future<void> _onAccept(LearningItem item) async {
    if (item.id == _target.id) {
      SfxService.success();
      await widget.progress.awardBonusStars(3);
      widget.tts.speak('Great match. You earned three stars.');
      setState(() {
        _round += 1;
        _message = 'Great match. You earned 3 stars.';
        _pickTarget();
      });
    } else {
      SfxService.error();
      widget.tts.speak('Almost. Try matching ${_target.title}.');
      setState(() => _message = 'Almost. Try matching ${_target.title}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 740;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Shape Match',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w900)),
                          ),
                          Text('Round $_round',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B9A), Color(0xFFFFCA3A)]),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.extension_rounded,
                                color: Colors.white, size: 46),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(_message,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Flex(
                        direction: wide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: wide ? 4 : 0,
                            child: _Portal(
                              target: _target,
                              onAccept: _onAccept,
                            ),
                          ),
                          SizedBox(width: wide ? 24 : 0, height: wide ? 0 : 24),
                          Expanded(
                            flex: wide ? 5 : 0,
                            child: Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              alignment: WrapAlignment.center,
                              children: _items
                                  .map(
                                    (item) => Draggable<LearningItem>(
                                      data: item,
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: _MatchTile(
                                            item: item, floating: true),
                                      ),
                                      childWhenDragging: Opacity(
                                          opacity: 0.35,
                                          child: _MatchTile(item: item)),
                                      child: _MatchTile(item: item),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Portal extends StatelessWidget {
  const _Portal({
    required this.target,
    required this.onAccept,
  });

  final LearningItem target;
  final ValueChanged<LearningItem> onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<LearningItem>(
      onAccept: onAccept,
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: active ? target.color.withOpacity(0.22) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: target.color, width: active ? 5 : 3),
            boxShadow: [
              BoxShadow(
                  color: target.color.withOpacity(0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 12)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 70, color: target.color),
              const SizedBox(height: 10),
              const Text('Match this',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              Text(target.title,
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: target.color)),
            ],
          ),
        );
      },
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.item, this.floating = false});

  final LearningItem item;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: floating ? 118 : 104,
      height: floating ? 118 : 104,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: item.color, width: 3),
        boxShadow: [
          BoxShadow(
              color: item.color.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: item.color, size: 34),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(item.title,
                style: TextStyle(
                    color: item.color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
