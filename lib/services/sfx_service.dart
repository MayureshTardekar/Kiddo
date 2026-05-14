import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SfxService {
  SfxService._();

  static final AudioPlayer _player = AudioPlayer();
  static bool enabled = true;

  static Future<void> tap() => _play('tap.mp3');
  static Future<void> success() => _play('sucess.mp3');
  static Future<void> error() => _play('error.mp3');

  static Future<void> _play(String fileName) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(fileName));
    } catch (error) {
      debugPrint('SFX skipped: $error');
    }
  }
}
