import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../services/sfx_service.dart';
import '../services/tts_service.dart';
import 'dashboard_screen.dart';
import 'practice_screen.dart';
import 'profile_screen.dart';
import 'quiz_screen.dart';
import 'rewards_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProgressService _progress = ProgressService();
  final TtsService _tts = TtsService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _progress.addListener(_refresh);
    _tts.addListener(_refresh);
    _load();
  }

  Future<void> _load() async {
    await _progress.load();
    _tts.setEnabled(_progress.ttsEnabled);
    SfxService.enabled = _progress.sfxEnabled;
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _progress.removeListener(_refresh);
    _tts.removeListener(_refresh);
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_progress.loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      DashboardScreen(
        progress: _progress,
        tts: _tts,
        onOpenLearn: () => setState(() => _selectedIndex = 1),
        onOpenQuest: () => setState(() => _selectedIndex = 2),
        onOpenRewards: () => setState(() => _selectedIndex = 3),
      ),
      PracticeScreen(progress: _progress, tts: _tts),
      QuizScreen(progress: _progress, tts: _tts),
      RewardsScreen(progress: _progress),
      ProfileScreen(progress: _progress, tts: _tts),
    ];

    return Scaffold(
      body: SafeArea(
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          SfxService.tap();
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_rounded),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_rounded),
            label: 'Quest',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_rounded),
            label: 'Rewards',
          ),
          NavigationDestination(icon: Icon(Icons.face_rounded), label: 'Me'),
        ],
      ),
    );
  }
}
