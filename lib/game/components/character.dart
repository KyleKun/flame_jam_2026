import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_jam_2026/game/my_game.dart';
import 'package:flutter/animation.dart';

class Character extends SpriteComponent with HasGameReference<MyGame> {
  String _imagePath;
  final double characterHeight;

  RotateEffect? _talkEffect;
  RotateEffect? _walkEffect;

  Character({
    required String imagePath,
    required super.position,
    this.characterHeight = 400,
  }) : _imagePath = imagePath,
       super(anchor: Anchor.bottomCenter, priority: 10) {
    paint = ui.Paint()
      ..filterQuality = ui.FilterQuality.high
      ..isAntiAlias = true;
  }

  @override
  Future<void> onLoad() async {
    _applySprite();
  }

  void setImagePath(String imagePath) {
    _imagePath = imagePath;
    _applySprite();
  }

  void _applySprite() {
    sprite = Sprite(game.images.fromCache(_imagePath));

    final aspectRatio = sprite!.srcSize.x / sprite!.srcSize.y;
    size = Vector2(characterHeight * aspectRatio, characterHeight);
  }

  /// Brief wobble when a new dialogue line starts (not continuous).
  void playTalkBounce() {
    _talkEffect?.removeFromParent();
    angle = 0;

    _talkEffect = RotateEffect.by(
      0.05,
      EffectController(
        duration: 0.1,
        alternate: true,
        repeatCount: 3,
        curve: Curves.easeInOut,
      ),
    );
    _talkEffect!.onComplete = () {
      angle = 0;
      _talkEffect = null;
    };
    add(_talkEffect!);
  }

  void startWalking() {
    _talkEffect?.removeFromParent();
    _talkEffect = null;
    _walkEffect?.removeFromParent();
    angle = 0;

    _walkEffect = RotateEffect.by(
      0.12,
      EffectController(
        duration: 0.15,
        alternate: true,
        infinite: true,
        curve: Curves.easeInOut,
      ),
    );
    add(_walkEffect!);
  }

  void stopWalking() {
    _walkEffect?.removeFromParent();
    _walkEffect = null;
    angle = 0;
  }
}
