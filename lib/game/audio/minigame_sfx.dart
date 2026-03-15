import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

class MinigameSfx {
  static const slice = 'slice.mp3';
  static const bomb = 'bomb.mp3';
  static const win = 'win.mp3';
  static const error = 'error.mp3';
  static const goal = 'goal.mp3';
  static const woof = 'woof.mp3';
  static const fail = 'fail.mp3';

  static const _noteFiles = <String, String>{
    'c': 'c.mp3',
    'd': 'd.mp3',
    'e': 'e.mp3',
    'f': 'f.mp3',
    'g': 'g.mp3',
    'a': 'a.mp3',
  };

  static const _allFiles = [slice, bomb, win, error, goal, woof, fail];

  static AudioPool? _slicePool;
  static AudioPool? _bombPool;

  static Future<void> preload() async {
    for (final file in [..._allFiles, ..._noteFiles.values]) {
      try {
        await FlameAudio.audioCache.load(file);
      } catch (_) {}
    }

    try {
      _slicePool = await FlameAudio.createPool(slice, maxPlayers: 4);
    } catch (_) {}
    try {
      _bombPool = await FlameAudio.createPool(bomb, maxPlayers: 4);
    } catch (_) {}
  }

  static void playSlice() {
    try {
      _slicePool?.start(volume: 0.72);
    } catch (_) {}
  }

  static void playBomb() {
    try {
      _bombPool?.start(volume: 0.85);
    } catch (_) {}
  }

  static void playWin() {
    unawaited(_play(win, volume: 0.9));
  }

  static void playError() {
    unawaited(_play(error, volume: 1.0));
  }

  static void playGoal() {
    unawaited(_play(goal, volume: 1.0));
  }

  static void playWoof() {
    unawaited(_play(woof, volume: 0.9));
  }

  static void playFail() {
    unawaited(_play(fail, volume: 0.85));
  }

  static void playNote(String noteName) {
    final file = _noteFiles[noteName];
    if (file != null) {
      unawaited(_play(file, volume: 0.8));
    }
  }

  static Future<void> _play(String file, {required double volume}) async {
    try {
      await FlameAudio.play(file, volume: volume);
    } catch (_) {}
  }
}
