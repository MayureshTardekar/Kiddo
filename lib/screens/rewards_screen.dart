import 'package:flutter/material.dart';

import '../data/app_content.dart';
import '../models/app_models.dart';
import '../services/progress_service.dart';
import '../widgets/kiddo_widgets.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key, required this.progress});

  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760 ? 4 : 2;
        final compact = constraints.maxWidth < 430;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 940),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFCA3A), Color(0xFFFF6B9A)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rewards Room',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'Collect badges by winning stars.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StarPill(stars: progress.totalStars),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    itemCount: AppContent.badges.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: compact ? 0.72 : 0.86,
                    ),
                    itemBuilder: (context, index) {
                      final badge = AppContent.badges[index];
                      final unlocked = progress.isBadgeUnlocked(badge);
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: unlocked ? 1 : 0.55,
                        child: Container(
                          padding: EdgeInsets.all(compact ? 12 : 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: badge.color.withOpacity(0.32),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: badge.color.withOpacity(0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _BadgeArt(badge: badge, size: compact ? 78 : 96),
                              Text(
                                badge.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                unlocked
                                    ? 'Unlocked'
                                    : '${badge.requiredStars} stars needed',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: compact ? 12 : 14,
                                  color: unlocked
                                      ? const Color(0xFF00A676)
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
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

class _BadgeArt extends StatelessWidget {
  const _BadgeArt({required this.badge, required this.size});

  final BadgeItem badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      badge.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          _FallbackBadge(badge: badge, size: size),
    );
  }
}

class _FallbackBadge extends StatelessWidget {
  const _FallbackBadge({required this.badge, required this.size});

  final BadgeItem badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = badge.id.contains('number')
        ? Icons.rocket_launch_rounded
        : badge.id.contains('shape')
            ? Icons.diamond_rounded
            : badge.id.contains('champion')
                ? Icons.emoji_events_rounded
                : Icons.menu_book_rounded;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            badge.color.withOpacity(0.95),
            badge.color.withOpacity(0.55)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: badge.color.withOpacity(0.24),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.54),
    );
  }
}
