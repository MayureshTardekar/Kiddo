import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService extends ChangeNotifier {
  TtsService({bool enabled = true}) : _enabled = enabled {
    _ready = _configure();
  }

  final FlutterTts _tts = FlutterTts();
  late final Future<void> _ready;
  bool _enabled;
  String _caption = 'Tap any card to hear the guide.';

  bool get enabled => _enabled;
  String get caption => _caption;

  Future<void> _configure() async {
    try {
      await _tts.awaitSpeakCompletion(false);
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.44);
      await _tts.setPitch(1.08);
      await _tts.setVolume(1.0);
    } catch (error) {
      debugPrint('TTS setup skipped: $error');
    }
  }

  Future<void> speak(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    _caption = cleanText;
    notifyListeners();

    if (!_enabled) return;

    try {
      await _ready;
      await _tts.stop();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final result = await _tts.speak(cleanText);
      debugPrint('TTS speak result: $result');
    } catch (error) {
      _caption =
          'Voice engine unavailable. Check Android Text-to-Speech settings.';
      notifyListeners();
      debugPrint('TTS skipped: $error');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Some test and desktop environments do not register the plugin.
    }
  }

  void setEnabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    if (!value) {
      unawaited(stop());
      _caption = 'Voice narrator is off.';
    } else {
      _caption = 'Voice narrator is ready. Tap a card to listen.';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(stop());
    super.dispose();
  }
}
