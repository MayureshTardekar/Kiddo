import 'package:flutter/material.dart';

import '../models/app_models.dart';

class StarPill extends StatelessWidget {
  const StarPill({super.key, required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2BE),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFD166), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22FFCA3A),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFB703)),
          const SizedBox(width: 6),
          Text(
            '$stars',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class VoiceButton extends StatelessWidget {
  const VoiceButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.compact = false,
  });

  final bool enabled;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: enabled ? 'Replay voice' : 'Voice is muted',
      onPressed: onPressed,
      icon: Icon(enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
      iconSize: compact ? 20 : 24,
    );
  }
}

class MascotHeader extends StatelessWidget {
  const MascotHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stars,
  });

  final String title;
  final String subtitle;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFFFF6B9A), Color(0xFFFFCA3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x336C63FF),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                StarPill(stars: stars),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/logo.jpg',
              width: 132,
              height: 132,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: colors.first.withOpacity(0.24),
                blurRadius: 18,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 38),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LevelCard extends StatelessWidget {
  const LevelCard({
    super.key,
    required this.level,
    required this.unlocked,
    required this.rating,
    required this.onTap,
  });

  final GameLevel level;
  final bool unlocked;
  final int rating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.58,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          width: 230,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(level.assetPath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.1), BlendMode.darken),
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: level.color.withOpacity(0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.08),
                  Colors.black.withOpacity(0.3)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                      unlocked
                          ? Icons.play_circle_fill_rounded
                          : Icons.lock_rounded,
                      color: Colors.white,
                      size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                        3,
                        (index) => Icon(
                          index < rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFFFD166),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(level.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                    Text(level.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LearningTile extends StatelessWidget {
  const LearningTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final LearningItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('learning-${item.id}'),
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? item.color.withOpacity(0.16) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: selected ? item.color : item.color.withOpacity(0.32),
              width: selected ? 3 : 2),
          boxShadow: [
            BoxShadow(
                color: item.color.withOpacity(selected ? 0.22 : 0.08),
                blurRadius: selected ? 18 : 10,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 34),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(item.title,
                  style: TextStyle(
                      color: item.color,
                      fontSize: 30,
                      fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.option,
    required this.isCorrect,
    required this.enabled,
    required this.onTap,
  });

  final String option;
  final bool isCorrect;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: ValueKey(isCorrect ? 'correct-answer' : 'answer-$option'),
      onPressed: enabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(130, 74),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF24304F),
        disabledBackgroundColor: Colors.white,
        elevation: 8,
        shadowColor: const Color(0x226C63FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        side: const BorderSide(color: Color(0xFFE6E9FF), width: 2),
      ),
      child: FittedBox(
        child: Text(option,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
