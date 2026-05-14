import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../services/sfx_service.dart';
import '../services/tts_service.dart';
import '../widgets/kiddo_widgets.dart';
import 'match_game_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.progress,
    required this.tts,
    required this.onOpenLearn,
    required this.onOpenQuest,
    required this.onOpenRewards,
  });

  final ProgressService progress;
  final TtsService tts;
  final VoidCallback onOpenLearn;
  final VoidCallback onOpenQuest;
  final VoidCallback onOpenRewards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 720;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MascotHeader(
                    title: 'Kiddo Adventure',
                    subtitle:
                        'A bright learning quest with voice, games, and badges.',
                    stars: progress.totalStars,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _StatPanel(
                          title: 'Best Score',
                          value: '${progress.bestScore}',
                          color: const Color(0xFF4D96FF),
                          icon: Icons.bolt_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatPanel(
                          title: 'Badges',
                          value: '${progress.progress.unlockedBadgeIds.length}',
                          color: const Color(0xFFFF6B9A),
                          icon: Icons.workspace_premium_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Choose your adventure',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: wide ? 4 : 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: wide ? 1.05 : 0.95,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ActionTile(
                        title: 'Practice',
                        subtitle: 'Tap and hear',
                        icon: Icons.auto_stories_rounded,
                        colors: const [Color(0xFF00C2A8), Color(0xFF57CC99)],
                        onTap: () {
                          SfxService.tap();
                          onOpenLearn();
                        },
                      ),
                      ActionTile(
                        title: 'Quiz Quest',
                        subtitle: 'Win more stars',
                        icon: Icons.explore_rounded,
                        colors: const [Color(0xFF6C63FF), Color(0xFF4D96FF)],
                        onTap: () {
                          SfxService.tap();
                          onOpenQuest();
                        },
                      ),
                      ActionTile(
                        title: 'Shape Match',
                        subtitle: 'Drag to match',
                        icon: Icons.extension_rounded,
                        colors: const [Color(0xFFFF6B9A), Color(0xFFFF9671)],
                        onTap: () {
                          SfxService.tap();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  MatchGameScreen(progress: progress, tts: tts),
                            ),
                          );
                        },
                      ),
                      ActionTile(
                        title: 'Rewards',
                        subtitle: 'Collect badges',
                        icon: Icons.workspace_premium_rounded,
                        colors: const [Color(0xFFFFCA3A), Color(0xFFFF9F1C)],
                        onTap: () {
                          SfxService.tap();
                          onOpenRewards();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: const Color(0xFFE6E9FF), width: 2),
                    ),
                    child: Row(
                      children: [
                        VoiceButton(
                          enabled: tts.enabled,
                          onPressed: () => tts.speak(
                              'Welcome to Kiddo Adventure. Choose practice, quiz quest, or shape match.'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tts.caption,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15),
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
    );
  }
}

class _StatPanel extends StatelessWidget {
  const _StatPanel({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.25), width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.14),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13)),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
