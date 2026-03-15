import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame_jam_2026/game/my_game.dart';

class SceneBackground extends SpriteComponent with HasGameReference<MyGame> {
  final String imagePath;

  SceneBackground({required this.imagePath})
    : super(anchor: Anchor.center, position: Vector2.zero(), priority: -1) {
    paint = ui.Paint()
      ..filterQuality = ui.FilterQuality.high
      ..isAntiAlias = true;
  }

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache(imagePath));
    size = Vector2(1280, 720);
  }
}
