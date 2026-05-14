import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../services/sfx_service.dart';
import '../services/tts_service.dart';
import '../widgets/kiddo_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.progress,
    required this.tts,
  });

  final ProgressService progress;
  final TtsService tts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MascotHeader(
                title: 'Little Explorer',
                subtitle: 'Settings, stats, and parent controls.',
                stars: progress.totalStars,
              ),
              const SizedBox(height: 18),
              _SettingsPanel(progress: progress, tts: tts),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE6E9FF), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Learning Stats',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    _StatRow(
                        label: 'Total stars', value: '${progress.totalStars}'),
                    _StatRow(
                        label: 'Best quiz score',
                        value: '${progress.bestScore}'),
                    _StatRow(
                        label: 'Badges unlocked',
                        value: '${progress.progress.unlockedBadgeIds.length}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.progress,
    required this.tts,
  });

  final ProgressService progress;
  final TtsService tts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6E9FF), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Parent Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Voice narrator',
                style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text(
                tts.enabled ? 'Voice narrator is on' : 'Voice narrator is off'),
            value: tts.enabled,
            onChanged: (value) async {
              await progress.setTtsEnabled(value);
              tts.setEnabled(value);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sound effects',
                style: TextStyle(fontWeight: FontWeight.w900)),
            subtitle: Text(progress.sfxEnabled
                ? 'Tap and reward sounds are on'
                : 'Sound effects are off'),
            value: progress.sfxEnabled,
            onChanged: (value) async {
              await progress.setSfxEnabled(value);
              SfxService.enabled = value;
            },
          ),
          const Divider(height: 28),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE63946)),
            onPressed: () async {
              final reset = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset progress?'),
                  content: const Text(
                      'This clears stars, badges, and level progress.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Reset')),
                  ],
                ),
              );
              if (reset == true) {
                await progress.reset();
                tts.setEnabled(true);
                SfxService.enabled = true;
              }
            },
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset Progress'),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w800))),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
    );
  }
}
