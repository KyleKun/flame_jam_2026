import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

class MinigameSfx {
  static const slice = 'kitchen/slice_placeholder.wav';
  static const bomb = 'kitchen/bomb_placeholder.wav';
  static const win = 'kitchen/win_placeholder.wav';

  static const _allFiles = [slice, bomb, win];

  static Future<void> preload() async {
    for (final file in _allFiles) {
      try {
        await FlameAudio.audioCache.load(file);
      } catch (_) {
        // Placeholder assets are optional during development.
      }
    }
  }

  static void playSlice() {
    unawaited(_play(slice, volume: 0.72));
  }

  static void playBomb() {
    unawaited(_play(bomb, volume: 0.85));
  }

  static void playWin() {
    unawaited(_play(win, volume: 0.9));
  }

  static Future<void> _play(String file, {required double volume}) async {
    try {
      await FlameAudio.play(file, volume: volume);
    } catch (_) {
      // Placeholder assets are optional during development.
    }
  }
}
