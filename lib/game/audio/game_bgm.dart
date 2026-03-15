import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';

class GameBgm {
  static const selectplayer = 'selectplayer.mp3';
  static const sala = 'sala.mp3';
  static const suspense = 'suspense.mp3';
  static const kitchen = 'kitchen.mp3';
  static const soccer = 'soccer.mp3';
  static const bathroom = 'bathroom.mp3';
  static const musicroom = 'musicroom.mp3';
  static const room = 'room.mp3';
  static const fronthouse = 'fronthouse.mp3';
  static const credits = 'credits.mp3';

  static const _allFiles = [
    selectplayer,
    sala,
    suspense,
    kitchen,
    soccer,
    bathroom,
    musicroom,
    room,
    fronthouse,
    credits,
  ];

  static AudioPlayer? _oneShotPlayer;
  static StreamSubscription<void>? _oneShotSub;

  static Future<void> preload() async {
    FlameAudio.bgm.initialize();
    for (final file in _allFiles) {
      try {
        await FlameAudio.audioCache.load(file);
      } catch (_) {}
    }
  }

  static void play(String file, {double volume = 0.5}) {
    _stopOneShot();
    FlameAudio.bgm.play(file, volume: volume);
  }

  static void stop() {
    _stopOneShot();
    FlameAudio.bgm.stop();
  }

  static void pause() {
    FlameAudio.bgm.pause();
  }

  static void resume() {
    FlameAudio.bgm.resume();
  }

  /// Play once (no loop). Calls [onComplete] when the track finishes.
  static Future<void> playOnce(
    String file, {
    double volume = 0.5,
    VoidCallback? onComplete,
  }) async {
    // Stop any current bgm or previous one-shot.
    FlameAudio.bgm.stop();
    _stopOneShot();

    try {
      final player = AudioPlayer();
      _oneShotPlayer = player;
      await player.setSource(AssetSource('audio/$file'));
      await player.setVolume(volume);
      await player.resume();

      _oneShotSub = player.onPlayerComplete.listen((_) {
        _stopOneShot();
        onComplete?.call();
      });
    } catch (_) {}
  }

  static void _stopOneShot() {
    _oneShotSub?.cancel();
    _oneShotSub = null;
    _oneShotPlayer?.dispose();
    _oneShotPlayer = null;
  }
}
